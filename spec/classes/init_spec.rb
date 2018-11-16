require 'spec_helper'

describe 'bamboo' do
  context 'unsupported operating systems' do
    let(:facts) { { osfamily: 'Windows' } }

    it { expect { catalogue }.to raise_error(Puppet::Error, %r{not supported}) }
  end

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'default parameters' do
          let(:params) { {} }

          it { is_expected.to contain_anchor('bamboo::start').that_comes_before('Class[bamboo::install]') }
          it { is_expected.to contain_class('bamboo') }
          it { is_expected.to contain_class('bamboo::params') }
          it { is_expected.to contain_class('bamboo::install').that_comes_before('Class[bamboo::facts]') }
          it { is_expected.to contain_class('bamboo::facts').that_comes_before('Class[bamboo::configure]') }
          it { is_expected.to contain_class('bamboo::configure').that_notifies('Class[bamboo::service]') }
          it { is_expected.to contain_class('bamboo::service').that_comes_before('Anchor[bamboo::end]') }
          it { is_expected.to contain_anchor('bamboo::end') }
        end

        context 'invalid parameters' do
          context 'version' do
            let(:params) { { version: 'invalid' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{does not match}) }
          end

          context 'extension' do
            let(:params) { { extension: '.exe' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{does not match}) }
          end

          context 'installdir' do
            let(:params) { { installdir: 'notabsolute' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{not an absolute path}) }
          end

          context 'homedir' do
            let(:params) { { homedir: 'aint_valid' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{not an absolute path}) }
          end

          context 'context_path' do
            let(:params) { { context_path: ['invalid'] } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{not a string}) }
          end

          context 'tomcat_port' do
            let(:params) { { tomcat_port: 'none' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{Expected first argument to be an Integer}) }
          end

          context 'max_threads' do
            let(:params) { { max_threads: 'invalid' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{Expected first argument to be an Integer}) }
          end

          context 'min_spare_threads' do
            let(:params) { { min_spare_threads: 'invalid' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{Expected first argument to be an Integer}) }
          end

          context 'connection_timeout' do
            let(:params) { { connection_timeout: 'invalid' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{Expected first argument to be an Integer}) }
          end

          context 'accept_count' do
            let(:params) { { accept_count: 'valid' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{Expected first argument to be an Integer}) }
          end

          context 'proxy' do
            let(:params) { { proxy: 'this is wrong' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{is not a Hash}) }
          end

          context 'manage_user' do
            let(:params) { { manage_user: 'jdoe' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{not a boolean}) }
          end

          context 'manage_group' do
            let(:params) { { manage_group: 'sdoe' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{not a boolean}) }
          end

          context 'user' do
            let(:params) { { user: 'not$valid' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{does not match}) }
          end

          context 'group' do
            let(:params) { { group: 'not%this one' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{does not match}) }
          end

          context 'uid' do
            let(:params) { { uid: 'denver' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{Expected first argument to be an Integer}) }
          end

          context 'gid' do
            let(:params) { { gid: 'colorado' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{Expected first argument to be an Integer}) }
          end

          context 'password' do
            let(:params) { { password: ['yeah, should be string'] } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{not a string}) }
          end

          context 'shell' do
            let(:params) { { shell: 'nologin' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{not an absolute path}) }
          end

          context 'java_home' do
            let(:params) { { java_home: 'idunno' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{not an absolute path}) }
          end

          context 'jvm_xms' do
            let(:params) { { jvm_xms: 'invalid' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{does not match}) }
          end

          context 'jvm_xmx' do
            let(:params) { { jvm_xmx: 'lazy' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{does not match}) }
          end

          context 'jvm_permgen' do
            let(:params) { { jvm_permgen: 'notnum' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{does not match}) }
          end

          context 'jvm_opts' do
            let(:params) { { jvm_opts: ['should be a string'] } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{not a string}) }
          end

          context 'jvm_optional' do
            let(:params) { { jvm_optional: ['also should be string'] } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{not a string}) }
          end

          context 'download_url' do
            let(:params) { { download_url: '//path/to/my/bsod' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{does not match}) }
          end

          context 'manage_service' do
            let(:params) { { manage_service: 'sure' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{not a boolean}) }
          end

          context 'service_ensure' do
            let(:params) { { service_ensure: 'definitely' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{does not match}) }
          end

          context 'service_enable' do
            let(:params) { { service_enable: 'yes' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{not a boolean}) }
          end

          context 'service_file' do
            let(:params) { { service_file: 'init.d/bamboo' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{not an absolute path}) }
          end

          context 'service_template' do
            let(:params) { { service_template: 'foo.erb' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{should be modulename\/path}) }
          end

          context 'shutdown_wait' do
            let(:params) { { shutdown_wait: 'false' } }

            it { expect { catalogue }.to raise_error(Puppet::Error, %r{Expected first argument to be an Integer}) }
          end
        end
      end
    end
  end
end
