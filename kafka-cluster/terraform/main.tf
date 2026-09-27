locals {
  nodes = {
    kafka-1 = { id = 1, private_ip = "10.20.1.11" }
    kafka-2 = { id = 2, private_ip = "10.20.1.12" }
    kafka-3 = { id = 3, private_ip = "10.20.1.13" }
  }

  common_tags = {
    Name = var.cluster_name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_vpc" "kafka" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-vpc" })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.kafka.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-public-subnet" })
}

resource "aws_internet_gateway" "kafka" {
  vpc_id = aws_vpc.kafka.id

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-igw" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.kafka.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kafka.id
  }

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-public-routes" })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "kafka" {
  name        = "${var.cluster_name}-nodes"
  description = "Restricted Kafka client access and private cluster traffic"
  vpc_id      = aws_vpc.kafka.id

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-nodes-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "external_kafka" {
  security_group_id = aws_security_group.kafka.id
  description       = "Kafka client listener from the single configured public IPv4 address"
  cidr_ipv4         = var.allowed_client_cidr
  ip_protocol       = "tcp"
  from_port         = 9094
  to_port           = 9094
}

resource "aws_vpc_security_group_ingress_rule" "internal_kafka" {
  security_group_id            = aws_security_group.kafka.id
  description                  = "Inter-broker traffic within this cluster"
  referenced_security_group_id = aws_security_group.kafka.id
  ip_protocol                  = "tcp"
  from_port                    = 9092
  to_port                      = 9092
}

resource "aws_vpc_security_group_ingress_rule" "zookeeper_client" {
  security_group_id            = aws_security_group.kafka.id
  description                  = "ZooKeeper client traffic within this cluster"
  referenced_security_group_id = aws_security_group.kafka.id
  ip_protocol                  = "tcp"
  from_port                    = 2181
  to_port                      = 2181
}

resource "aws_vpc_security_group_ingress_rule" "zookeeper_quorum" {
  security_group_id            = aws_security_group.kafka.id
  description                  = "ZooKeeper quorum traffic within this cluster"
  referenced_security_group_id = aws_security_group.kafka.id
  ip_protocol                  = "tcp"
  from_port                    = 2888
  to_port                      = 3888
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.kafka.id
  description       = "Outbound package downloads and Systems Manager access"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_iam_role" "kafka_node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "systems_manager" {
  role       = aws_iam_role.kafka_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "kafka_node" {
  name = "${var.cluster_name}-node-profile"
  role = aws_iam_role.kafka_node.name

  tags = local.common_tags
}

resource "aws_instance" "kafka_node" {
  for_each = local.nodes

  ami                         = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  private_ip                  = each.value.private_ip
  vpc_security_group_ids      = [aws_security_group.kafka.id]
  iam_instance_profile        = aws_iam_instance_profile.kafka_node.name
  user_data                   = templatefile("${path.module}/scripts/bootstrap-kafka.sh.tftpl", {
    kafka_version   = var.kafka_version
    node_id         = each.value.id
    node_private_ip = each.value.private_ip
  })
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.data_volume_size_gib
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-${each.key}"
    Role = "kafka-zookeeper"
  })

  depends_on = [aws_route_table_association.public, aws_iam_role_policy_attachment.systems_manager]
}
