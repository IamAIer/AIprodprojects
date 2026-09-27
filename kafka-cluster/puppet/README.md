# Puppet configuration management

This directory contains a standalone Puppet module for the three-node Kafka/ZooKeeper demo cluster. It manages Kafka and ZooKeeper property files and ensures their systemd services stay enabled and running. It does not create AWS resources or a Puppet Server.

Terraform and the node's first-boot script create the servers, install Kafka, and start the services. Use Puppet after the servers are ready to apply the checked-in configuration. The deployment procedure is in [`../terraform/README.md`](../terraform/README.md).

## Install Puppet on each node

Connect to each EC2 node with AWS Systems Manager Session Manager. Install the Puppet agent by following Puppet's current [Linux instructions](https://help.puppet.com/core/current/Content/PuppetCore/install_nix_agents.htm). Puppet Core packages are in protected repositories and require a Puppet account and repository credentials. The account offers a free signup; you do not need to put its API key in Terraform, user data, or this repository. Configure credentials locally on each node as directed by Puppet.

Puppet supports Amazon Linux 2023. The open-source Puppet packages for Amazon Linux 2023 have reached end of life, so use the current maintained Puppet Core packages instead of the old open-source packages. See [supported operating systems](https://help.puppet.com/core/current/Content/PuppetCore/supported_operating_systems.htm) and the [Puppet lifecycle](https://help.puppet.com/osp/current/Content/PuppetCore/platform_lifecycle.htm).

## Apply the module

If this public repository has been merged to `main`, run these commands on each node in Session Manager:

```bash
sudo dnf install -y git
sudo git clone https://github.com/IamAIer/AIprodprojects.git /opt/aiprodprojects
sudo /opt/aiprodprojects/kafka-cluster/puppet/apply-kafka.sh
```

The script reads the broker ID from `/var/lib/zookeeper/myid`, detects the node's local addresses, and runs `puppet apply` using the module in the repository checkout. It does not need AWS credentials or contact Kafka brokers. If the repository is private, use an approved secure way to make the files available; do not put a GitHub token in shell history or user data.

Puppet is applied on demand by this guide; no Puppet Server or periodic timer is installed. If you want automatic repeat runs later, choose an update schedule and change policy first.
