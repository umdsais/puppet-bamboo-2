require 'spec_helper_acceptance'

describe 'bamboo class', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
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

      # Figure out how to install OpenJDK
      if $::osfamily == 'Debian' {
        $java_home = "/usr/lib/jvm/java-8-openjdk-${::architecture}"
        if $::facts['operatingsystem'] == 'Ubuntu' {
          $package = 'openjdk-8-jdk'
          $package_options = undef
        } else {
          $package = 'openjdk-8-jdk'
          if $::facts['operatingsystemmajrelease'] == '8' {
            $package_options = [{'-t' => 'jessie-backports'}]
          }
        }
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
				java_home    => $java_home,
        download_url => $download_url,
        version      => $version,
        umask        => 0022,
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
