# Puppet configuration management

This directory contains a standalone Puppet module for the existing three-node Kafka/ZooKeeper stack. It manages the Kafka and ZooKeeper property files and keeps their systemd services enabled and running. It does not create a Puppet Server, another EC2 instance, or any AWS resources.

The CloudFormation user data remains responsible for the initial operating-system, Java, and Kafka installation. Puppet then owns the service configuration. Run `apply-kafka.sh` on each node whenever you want to reapply the checked-in configuration. `puppet apply` is a one-time local run; this design has no always-on Puppet server or automatic periodic runs.

## Install the Puppet executable

Install the open-source Puppet agent package on each node using Puppet's current Amazon Linux 2023 instructions. Puppet's package repository may require a free account/registration and repository credentials. Follow Puppet's current official instructions; keep credentials on the instance and do not commit them, pass them as CloudFormation parameters, or put them in user data. Do not install Puppet Enterprise for this demo.

Official references:

- [Supported operating systems](https://help.puppet.com/core/current/Content/PuppetCore/supported_operating_systems.htm) (Amazon Linux 2023)
- [Install *nix agents](https://help.puppet.com/core/current/Content/PuppetCore/install_nix_agents.htm)
- [Puppet apply](https://help.puppet.com/core/current/Content/PuppetCore/Markdown/apply.htm)

The stack already has Systems Manager enabled. Use Session Manager to connect to each of the three nodes. If the repository is public, fetch the merged `main` branch on each node and run the apply script:

```bash
sudo dnf install -y git
sudo git clone https://github.com/IamAIer/AIprodprojects.git /opt/aiprodprojects
cd /opt/aiprodprojects
sudo ./kafka-cluster/puppet/apply-kafka.sh
```

If the repository is private, use your approved secure method to make the Puppet directory available on each node; do not put a GitHub token into shell history, user data, or the repository.

The script reads the broker ID and private/public IPs locally, writes them as local Facter facts, and applies the module from the repository checkout. It does not need AWS credentials or make AWS API calls. The module requires the existing `/opt/kafka` install and systemd units created by CloudFormation user data.

## Drift and cleanup

Configuration is only reapplied when you run the script. To make it recurring, add a scheduled Puppet apply after deciding on an update policy; this example deliberately does not install a timer. Deleting the CloudFormation stack deletes the EC2 instances and their attached volumes, along with Puppet and Kafka state on them. No Puppet Server or separate AWS resource needs cleanup.
