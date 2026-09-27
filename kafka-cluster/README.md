# Three-node Kafka demo cluster

This folder contains a disposable three-node Apache Kafka and ZooKeeper cluster for learning. Terraform creates the AWS resources, and each server's first-boot script installs Kafka and writes its broker settings.

This is not a production design. It uses Kafka 3.9.2 in ZooKeeper mode because Kafka 4 removed ZooKeeper support. Client traffic uses plaintext. Open port 9094 only to your own public IPv4 address (`/32`).

## Deploy with Terraform

Follow the [Terraform deployment guide](terraform/README.md). It creates the VPC, subnet, security group, IAM role, and three EC2 servers in Mumbai (`ap-south-1` by default). Terraform does not deploy the separate Bedrock Jira assistant.

The EC2 servers have no SSH access. Use AWS Systems Manager Session Manager. Terraform creates an IAM role for Session Manager, and the Amazon Linux 2023 image includes its agent.

## Remove the demo

Run `terraform destroy` from `terraform/` and review its plan before confirming. This deletes the servers, network, and Kafka data stored on their volumes. Export any data you need first. AWS charges continue while the demo resources are running, so remove the stack when finished.
