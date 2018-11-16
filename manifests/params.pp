class bamboo::params {

  case $::osfamily {
    'RedHat': {
      $initconfig_path = '/etc/sysconfig/bamboo'
      if $::operatingsystemmajrelease == '7' {
        $service_file     = '/usr/lib/systemd/system/bamboo.service'
        $service_template = 'bamboo/bamboo.service.erb'
      }
      elsif $::operatingsystemmajrelease == '6' or $::operatingsystem == 'Amazon'{
        $service_file     = '/etc/init.d/bamboo'
        $service_template = 'bamboo/bamboo.init.erb'
      }
      else {
        fail("${::osfamily} ${::operatingsystemmajrelease} not supported.")
      }
    }

    'Debian': {
      $initconfig_path  = '/etc/default/bamboo'
      case $::operatingsystem {
        'Ubuntu': {
          if versioncmp($::operatingsystemmajrelease, '16') >= 0 {
            $service_file     = '/lib/systemd/system/bamboo.service'
            $service_template = 'bamboo/bamboo.service.erb'
          }
          else {
            $service_file     = '/etc/init.d/bamboo'
            $service_template = 'bamboo/bamboo.init.erb'
          }
        }
        'Debian': {
          if versioncmp($::operatingsystemmajrelease, '8') == 0 {
            $service_file     = '/lib/systemd/system/bamboo.service'
            $service_template = 'bamboo/bamboo.service.erb'
          } elsif versioncmp($::operatingsystemmajrelease, '9') >= 0 {
            $service_file     = '/etc/systemd/system/bamboo.service'
            $service_template = 'bamboo/bamboo.service.erb'
          }
          else {
            $service_file     = '/etc/init.d/bamboo'
            $service_template = 'bamboo/bamboo.init.erb'
          }
        }
        default: {
          fail("The bamboo module is not supported on ${::operatingsystem}")
        }
      }

    }

    'Windows': {
      fail('The bamboo module is not supported on Windows')
    }

    default: {
      fail("The bamboo module is not supported on ${::osfamily}")
    }
  }


  # Where to stick the external fact for reporting the version
  # Refer to:
  #   https://docs.puppet.com/facter/3.5/custom_facts.html#fact-locations
  #   https://github.com/puppetlabs/facter/commit/4bcd6c87cf00609f28be23f6463a3d76d0b6613c
  if versioncmp($::facterversion, '2.4.2') >= 0 {
    $facter_dir = '/opt/puppetlabs/facter/facts.d'
  }
  else {
    $facter_dir = '/etc/puppetlabs/facter/facts.d'
  }

  $stop_command = 'service bamboo stop && sleep 10'

}
