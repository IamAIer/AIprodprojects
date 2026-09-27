# AIprodprojects

Project code and deployment infrastructure. Changes are reviewed and merged through pull requests.

## Kafka development cluster

The `kafka-cluster/` directory contains a Terraform deployment for a disposable three-node Apache Kafka cluster. Each EC2 node runs one Kafka broker and one ZooKeeper member. See [the deployment guide](kafka-cluster/terraform/README.md) before launching it.

The optional [Puppet module](kafka-cluster/puppet/README.md) applies Kafka and ZooKeeper configuration on the nodes with standalone `puppet apply`; it adds no Puppet Server or AWS resources.

Merging this code updates GitHub only. It does not deploy to AWS. AWS resources are created only when you review and run `terraform apply` yourself.
