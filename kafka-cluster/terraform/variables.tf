variable "aws_region" {
  description = "AWS Region where the demo cluster will be created."
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment label applied to created AWS resources."
  type        = string
  default     = "demo"
}

variable "cluster_name" {
  description = "Name prefix used for the Kafka demo resources."
  type        = string
  default     = "aiprod-kafka-demo-tf"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{2,39}$", var.cluster_name))
    error_message = "Use 3-40 letters, numbers, or hyphens, starting with a letter."
  }
}

variable "allowed_client_cidr" {
  description = "Your public IPv4 address with /32, allowed to connect to Kafka on port 9094."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.allowed_client_cidr)) && can(regex("/32$", var.allowed_client_cidr)) && var.allowed_client_cidr != "0.0.0.0/0"
    error_message = "Enter one public IPv4 address ending in /32, for example 203.0.113.10/32."
  }
}

variable "instance_type" {
  description = "EC2 size used for each Kafka and ZooKeeper node."
  type        = string
  default     = "t3.small"

  validation {
    condition     = contains(["t3.small", "t3.medium"], var.instance_type)
    error_message = "Choose t3.small or t3.medium."
  }
}

variable "kafka_version" {
  description = "Kafka version; 3.9.2 is pinned because it supports ZooKeeper mode."
  type        = string
  default     = "3.9.2"

  validation {
    condition     = var.kafka_version == "3.9.2"
    error_message = "This demo is pinned to Kafka 3.9.2."
  }
}

variable "data_volume_size_gib" {
  description = "Encrypted gp3 root/data volume size on each node. Volumes are deleted with the instances."
  type        = number
  default     = 20

  validation {
    condition     = var.data_volume_size_gib >= 20 && var.data_volume_size_gib <= 100
    error_message = "Choose a volume size from 20 to 100 GiB."
  }
}
