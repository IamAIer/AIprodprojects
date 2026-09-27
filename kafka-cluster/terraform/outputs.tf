output "kafka_bootstrap_servers" {
  description = "PLAINTEXT Kafka bootstrap servers on port 9094. For restricted development use only."
  value       = join(",", [for name in sort(keys(aws_instance.kafka_node)) : "${aws_instance.kafka_node[name].public_ip}:9094"])
}

output "node_instance_ids" {
  description = "EC2 instance IDs; use these to connect through AWS Systems Manager Session Manager."
  value       = { for name, node in aws_instance.kafka_node : name => node.id }
}

output "node_public_ips" {
  description = "Public IP addresses for the three Kafka demo nodes."
  value       = { for name, node in aws_instance.kafka_node : name => node.public_ip }
}

output "aws_region" {
  description = "AWS Region selected for this deployment."
  value       = var.aws_region
}
