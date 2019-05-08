require 'spec_helper_acceptance'

describe 'bamboo class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-EOS

      # Allow for environment variables to specify custom download URLs/versions
      if !empty('#{BAMBOO_DOWNLOAD_URL}') {
        $download_url = '#{BAMBOO_DOWNLOAD_URL}'
        notice("BAMBOO_DOWNLOAD_URL is set. Using ${download_url}")
      } else {
        $download_url = undef
      }

      if !empty('#{BAMBOO_VERSION}') {
        $version = '#{BAMBOO_VERSION}'
        notice("BAMBOO_VERSION is set. Using ${version}")
      } else {
        $version = undef
      }

      # On Debian 9 and Ubuntu 18.04, we're just using the sysvinit, since there's issues with the systemd
      # service in the Docker containers.
      # Unfortunately, this doesn't really test real-world use of this module exactly.
      if (($facts['operatingsystem'] == 'Ubuntu' and $facts['os']['release']['full'] == '18.04') or ($facts['operatingsystem'] == 'Debian' and $facts['os']['release']['major'] == '9')) {
        $service_file = '/etc/init.d/bamboo'
        $service_template = 'bamboo/bamboo.init.erb'
        $service_mode = '0755'
        $reload_systemd = false
        $srvice_provider = 'debian'
      } else {
        $service_file = undef
        $service_template = undef
        $service_mode = undef
        $reload_systemd = false
        $srvice_provider = undef
      }

      # Figure out how to install OpenJDK
      if $::osfamily == 'Debian' {
        $java_home = "/usr/lib/jvm/java-8-openjdk-${::architecture}"
        $package = 'openjdk-8-jdk'
        $package_options = undef

      } elsif $::osfamily == 'RedHat' {
        $java_home = '/etc/alternatives/java_sdk'
        $package = 'java-1.8.0-openjdk-devel'
        $package_options = undef
      } else {
        $java_home = undef
        $package = undef
        $package_options = undef
      }

      class { 'java':
        package         => $package,
        package_options => $package_options,
      }

      class { 'bamboo':
				java_home         => $java_home,
        download_url      => $download_url,
        version           => $version,
        umask             => '0022',
        service_file      => $service_file,
        service_template  => $service_template,
        service_file_mode => $service_mode,
        reload_systemd    => $reload_systemd,
        service_provider  => $srvice_provider,
			}
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      shell('sleep 10')
      shell('ps aux | grep bamboo')
      apply_manifest(pp, catch_changes: true)
    end

    describe service('bamboo') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8085) do
      it { is_expected.to be_listening }
    end
  end
end
