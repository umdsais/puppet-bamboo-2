class bamboo::configure (
  $version            = $bamboo::version,
  $appdir             = $bamboo::real_appdir,
  $homedir            = $bamboo::homedir,
  $user               = $bamboo::user,
  $group              = $bamboo::group,
  $java_home          = $bamboo::java_home,
  $jvm_xmx            = $bamboo::jvm_xmx,
  $jvm_xms            = $bamboo::jvm_xms,
  $jvm_permgen        = $bamboo::jvm_permgen,
  $jvm_opts           = $bamboo::jvm_opts,
  $jvm_optional       = $bamboo::jvm_optional,
  $context_path       = $bamboo::context_path,
  $tomcat_port        = $bamboo::tomcat_port,
  $max_threads        = $bamboo::max_threads,
  $min_spare_threads  = $bamboo::min_spare_threads,
  $connection_timeout = $bamboo::connection_timeout,
  $proxy              = $bamboo::proxy,
  $accept_count       = $bamboo::accept_count,
) {

  file { "${appdir}/bin/setenv.sh":
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    mode    => '0755',
    content => template('bamboo/setenv.sh.erb'),
  }

  file { "${appdir}/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties":
    ensure  => 'file',
    owner   => $user,
    group   => $group,
    content => "bamboo.home=${homedir}",
  }

  $changes = [
    "set Server/Service[#attribute/name='Catalina']/Engine/Host/Context/#attribute/path '${context_path}'",
    "set Server/Service/Connector/#attribute/maxThreads '${max_threads}'",
    "set Server/Service/Connector/#attribute/minSpareThreads '${min_spare_threads}'",
    "set Server/Service/Connector/#attribute/connectionTimeout '${connection_timeout}'",
    "set Server/Service/Connector/#attribute/port '${tomcat_port}'",
    "set Server/Service/Connector/#attribute/acceptCount '${accept_count}'",
  ]

  if !empty($proxy) {
    $_proxy   = suffix(prefix(join_keys_to_values($proxy, " '"), 'set Server/Service/Connector[#attribute/protocol = "HTTP/1.1"]/#attribute/'), "'")
    $_changes = concat($changes, $_proxy)
  }
  else {
    $_proxy   = undef
    $_changes = $changes
  }

  augeas { "${appdir}/conf/server.xml":
    lens    => 'Xml.lns',
    incl    => "${appdir}/conf/server.xml",
    changes => $_changes,
  }

}
