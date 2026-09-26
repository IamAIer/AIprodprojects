class kafka {
  $node_id = Integer($facts['kafka_node_id'])
  $private_ip = $facts['kafka_private_ip']
  $public_ip = $facts['kafka_public_ip']

  if $node_id < 1 or $node_id > 3 {
    fail('kafka_node_id must be 1, 2, or 3')
  }

  file { '/opt/kafka/config/zookeeper.properties':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('kafka/zookeeper.properties.epp'),
    notify  => Service['zookeeper'],
  }

  file { '/opt/kafka/config/server.properties':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('kafka/server.properties.epp', {
      'node_id'    => $node_id,
      'private_ip' => $private_ip,
      'public_ip'  => $public_ip,
    }),
    notify  => Service['kafka'],
  }

  service { 'zookeeper':
    ensure     => running,
    enable     => true,
    name       => 'zookeeper.service',
    hasrestart => true,
  }

  service { 'kafka':
    ensure     => running,
    enable     => true,
    name       => 'kafka.service',
    hasrestart => true,
    require    => Service['zookeeper'],
  }
}
