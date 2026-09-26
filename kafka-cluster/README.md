# Three-node Kafka and ZooKeeper cluster

This is a small, disposable AWS demonstration cluster. Each of the three EC2 instances runs one Apache Kafka broker and one ZooKeeper member. CloudFormation owns the network, security group, IAM instance profile, instances, and EBS volumes so the whole stack can be removed from the AWS Console.

## Important limits

- This cluster uses Kafka 3.9.2 because Kafka 4.x removed ZooKeeper mode. ZooKeeper mode is deprecated; this setup follows the requested architecture and is for learning/interviews, not a new production service.
- Brokers and ZooKeeper use plaintext. Kafka's external port is restricted to `AllowedClientCidr`; use your current public IP as a `/32`. Do not set `0.0.0.0/0`.
- There is no SSH ingress rule. Use AWS Systems Manager Session Manager. Keep the instances in the public subnet so Session Manager and the initial package/download steps can reach their AWS and Apache endpoints without a NAT Gateway.
- The small default `t3.small` size and 20 GiB gp3 volume per node are intended for light demos. Kafka's first boot downloads the pinned Apache archive and validates its SHA-512 checksum.
- AWS charges for the three running instances, EBS volumes, and public IPv4 addresses. Stop or delete the stack when finished; stopping instances does not stop EBS and public IPv4 charges.

## Deploy from the AWS Console

1. Open **CloudFormation** in the AWS Region you intend to use.
2. Choose **Create stack → With new resources (standard)**.
3. Upload `cluster.yaml`.
4. Set a stack name such as `aiprod-kafka-demo`.
5. For `AllowedClientCidr`, enter your public IPv4 address with `/32` (for example, `203.0.113.10/32`). Choose `t3.small` for the lowest-cost demonstration option, or `t3.medium` for more memory. Keep Kafka version at `3.9.2`.
6. Acknowledge that CloudFormation may create IAM resources, then create the stack.
7. Wait for `CREATE_COMPLETE`. First boot downloads Kafka and can take several minutes. The `KafkaBootstrapServers` output lists the external broker endpoints.

## Verify and connect

- In EC2, confirm all three instances pass status checks.
- Use Session Manager to connect to a node, then check `systemctl status zookeeper kafka` and `/var/log/cloud-init-output.log`.
- Kafka clients should use the `PLAINTEXT` protocol and the `KafkaBootstrapServers` output on port `9094`.
- The stack does not create application topics. Create topics with replication factor `3` and `min.insync.replicas=2` for the intended three-broker behavior.
- The public IPs are assigned at launch and will change if instances are replaced. Read the CloudFormation outputs again after replacement.

## Delete every stack resource

1. In CloudFormation, select the stack and choose **Delete**.
2. Wait until the stack disappears or reaches `DELETE_COMPLETE`.
3. Confirm the three EC2 instances, attached EBS volumes, security group, VPC/network resources, and IAM role/profile are gone. The template marks EBS volumes for deletion with their instances and does not retain a bucket or data resource.

Deleting the stack permanently deletes Kafka data on the attached volumes. Export anything you need before deletion.

## Review before use

This template opens TCP `9094` only to the CIDR you provide; cluster coordination ports are allowed only between instances in this stack's security group. It grants the EC2 nodes the AWS-managed Systems Manager core policy and does not grant cluster instances permission to mutate other AWS resources. The cluster has no TLS, SASL, Kafka ACLs, or production backup/monitoring setup.
