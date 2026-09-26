# AIprodprojects

Project code and deployment infrastructure. Changes are reviewed and merged through pull requests.

## Kafka development cluster

The `kafka-cluster/` directory contains a CloudFormation template for a disposable three-node Apache Kafka cluster. Each EC2 node runs one Kafka broker and one ZooKeeper member. See [the deployment guide](kafka-cluster/README.md) before launching it.

Merging this template updates GitHub only. It does not deploy to AWS. AWS resources are created only when you manually run the CloudFormation deployment commands or create the stack in the AWS Console.
