# Private class to define default parameter values for Bamboo
#
class bamboo::params {

  case $facts['osfamily'] {
    'RedHat': {
      $initconfig_path = '/etc/sysconfig/bamboo'
      if $facts['operatingsystemmajrelease'] == '7' {
        $service_file      = '/usr/lib/systemd/system/bamboo.service'
        $service_template  = 'bamboo/bamboo.service.erb'
        $reload_systemd    = true
        $service_file_mode = '0644'
      }
      elsif $facts['operatingsystemmajrelease'] == '6' or $facts['operatingsystem'] == 'Amazon'{
        $service_file      = '/etc/init.d/bamboo'
        $service_template  = 'bamboo/bamboo.init.erb'
        $reload_systemd    = false
        $service_file_mode = '0755'
      }
      else {
        fail("${facts['osfamily']} ${facts['operatingsystemmajrelease']} not supported.")
      }
    }

    'Debian': {
      $initconfig_path  = '/etc/default/bamboo'
      case $facts['operatingsystem'] {
        'Ubuntu': {
          if versioncmp($facts['operatingsystemmajrelease'], '16') >= 0 {
            $service_file      = '/lib/systemd/system/bamboo.service'
            $service_template  = 'bamboo/bamboo.service.erb'
            $reload_systemd    = true
            $service_file_mode = '0644'
          }
          else {
            $service_file      = '/etc/init.d/bamboo'
            $service_template  = 'bamboo/bamboo.init.erb'
            $reload_systemd    = false
            $service_file_mode = '0755'
          }
        }
        'Debian': {
          if versioncmp($facts['operatingsystemmajrelease'], '8') == 0 {
            $service_file      = '/lib/systemd/system/bamboo.service'
            $service_template  = 'bamboo/bamboo.service.erb'
            $reload_systemd    = true
            $service_file_mode = '0644'
          } elsif versioncmp($facts['operatingsystemmajrelease'], '9') >= 0 {
            $service_file      = '/etc/systemd/system/bamboo.service'
            $service_template  = 'bamboo/bamboo.service.erb'
            $reload_systemd    = true
            $service_file_mode = '0644'
          }
          else {
            $service_file      = '/etc/init.d/bamboo'
            $service_template  = 'bamboo/bamboo.init.erb'
            $reload_systemd    = false
            $service_file_mode = '0755'
          }
        }
        default: {
          fail("The bamboo module is not supported on ${facts['operatingsystem']}")
        }
      }

    }

    'Windows': {
      fail('The bamboo module is not supported on Windows')
    }

    default: {
      fail("The bamboo module is not supported on ${facts['osfamily']}")
    }
  }


  # Where to stick the external fact for reporting the version
  # Refer to:
  #   https://docs.puppet.com/facter/3.5/custom_facts.html#fact-locations
  #   https://github.com/puppetlabs/facter/commit/4bcd6c87cf00609f28be23f6463a3d76d0b6613c
  if versioncmp($facts['facterversion'], '2.4.2') >= 0 {
    $facter_dir = '/opt/puppetlabs/facter/facts.d'
  }
  else {
    $facter_dir = '/etc/puppetlabs/facter/facts.d'
  }

  $stop_command = 'service bamboo stop && sleep 10'

}
