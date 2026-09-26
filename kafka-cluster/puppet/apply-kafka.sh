#!/usr/bin/env bash
set -euo pipefail

if [[ $(id -u) -ne 0 ]]; then
  echo 'Run this script as root (for example, sudo ./apply-kafka.sh).' >&2
  exit 1
fi

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
node_id=$(cat /var/lib/zookeeper/myid)
private_ip=$(ip -o -4 addr show scope global | awk '{split($4, a, "/"); if (a[1] ~ /^10\.20\.1\./) {print a[1]; exit}}')
token=$(curl --fail --silent --show-error -X PUT \
  -H 'X-aws-ec2-metadata-token-ttl-seconds: 60' \
  http://169.254.169.254/latest/api/token)
public_ip=$(curl --fail --silent --show-error \
  -H "X-aws-ec2-metadata-token: ${token}" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

if [[ ! "$node_id" =~ ^[1-3]$ || -z "$private_ip" || -z "$public_ip" ]]; then
  echo 'Unable to detect this Kafka node ID or its private/public IP addresses.' >&2
  exit 1
fi

fact_dir=/etc/puppetlabs/facter/facts.d
install -d -m 0755 "$fact_dir"
cat >"$fact_dir/kafka.txt" <<FACTS
kafka_node_id=${node_id}
kafka_private_ip=${private_ip}
kafka_public_ip=${public_ip}
FACTS
chmod 0644 "$fact_dir/kafka.txt"

/opt/puppetlabs/bin/puppet apply \
  --modulepath "$repo_root/kafka-cluster/puppet/modules" \
  -e 'include kafka'
