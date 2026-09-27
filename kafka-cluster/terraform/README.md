# Deploy the Kafka demo with Terraform

Terraform creates the AWS network, security rules, IAM role, and three EC2 nodes in `ap-south-1` by default. Each node gets Kafka 3.9.2 and ZooKeeper from first-boot setup. The first-boot script writes the broker and ZooKeeper settings and starts both services; no separate configuration tool is needed.

This is a small learning/demo cluster, not a production service. Kafka uses plaintext. Port 9094 is opened only to the one public IPv4 address you provide. The nodes have public IPs for package downloads and Session Manager; there is no SSH rule. AWS charges for running EC2 instances, EBS volumes, and public IPv4 addresses. Terraform itself does not make AWS resources free.

## Before you start

- Install Terraform CLI 1.6 or newer and AWS CLI v2.
- Sign in to the AWS account where you want the demo. Terraform uses the AWS CLI credentials already configured on your computer.
- Make sure the account can create VPC, EC2, IAM role/profile, and security group resources.
- Find your current public IPv4 address. Enter it with `/32` so only your address can reach Kafka.

If you already created the old CloudFormation stack, Terraform will not automatically take it over. This example uses a different resource name so the two stacks can be identified separately. Check for an existing stack before deploying to avoid running two paid clusters at once. Deleting a stack also deletes its Kafka data.

## Deploy

Open PowerShell at the repository root and run:

```powershell
aws sts get-caller-identity --region ap-south-1
Set-Location kafka-cluster/terraform
Copy-Item terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
```

Replace the example `allowed_client_cidr` with your public IPv4 address and `/32`. Then review the planned changes before creating anything:

```powershell
terraform init
terraform plan
terraform apply
```

Type `yes` only after the plan shows the resources you expect. `terraform apply` creates billable AWS resources. It does not configure an LLM, Jira, Datadog, or the separate Bedrock assistant. If Terraform needs to replace an EC2 node, its Kafka data volume is deleted.

After `apply` completes, copy the `kafka_bootstrap_servers` output if you need a client connection. It uses plaintext and is only for this restricted demo. Use the `node_instance_ids` output to open each server in AWS Systems Manager Session Manager.

## Stop and remove the demo

Stopping an EC2 instance still leaves EBS volumes and public IPv4 addresses that may cost money. When the cluster is no longer needed, run:

```powershell
terraform destroy
```

Review the destroy plan and type `yes` to remove the Terraform-managed stack. This deletes Kafka data on the node volumes. Export any data you need first. Terraform's local state file is needed to manage and destroy this deployment; keep it private and do not commit it.

## State file

Terraform stores its state locally in this folder by default. Back it up securely and do not share or commit it. If the computer holding this file is lost, Terraform may not be able to safely manage or remove the cluster until the state is recovered or AWS resources are imported.
