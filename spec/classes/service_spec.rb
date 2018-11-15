require 'spec_helper'

describe 'bamboo' do
  describe 'bamboo::service' do
    context 'supported operating systems' do
      on_supported_os.each do |os, facts|
        context "on #{os}" do
          let(:facts) do
            facts
          end
          context "bamboo::service class with default parameters" do
            case facts[:osfamily]
            when 'RedHat'
              if facts[:operatingsystemmajrelease].to_i >= 7
                it do
                  is_expected.to contain_file('/usr/lib/systemd/system/bamboo.service').with(
                    'content' => /^PIDFile=\/usr\/local\/bamboo\/atlassian-bamboo-6\.7\.1\/work\/catalina\.pid$/
                  )
                end
                it do
                  is_expected.to contain_file('/usr/lib/systemd/system/bamboo.service').with(
                    'content' => /^Environment="UMASK="$/
                  )
                end
              else
                it do
                  is_expected.to contain_file('/etc/init.d/bamboo').with(
                    'content' => /^export CATALINA_HOME=\/usr\/local\/bamboo\/atlassian-bamboo-6\.7\.1$/
                  )
                end
                it do
                  is_expected.to contain_file('/etc/init.d/bamboo').with(
                    'content' => /^export UMASK=$/
                  )
                end
              end
            when 'Debian'
              if facts[:operatingsystem].casecmp('ubuntu').zero?
                if facts[:operatingsystemmajrelease].to_i >= 16
                  it do
                    is_expected.to contain_file('/lib/systemd/system/bamboo.service').with(
                      'content' => /^PIDFile=\/usr\/local\/bamboo\/atlassian-bamboo-6\.7\.1\/work\/catalina\.pid$/
                    )
                  end
                  it do
                    is_expected.to contain_file('/lib/systemd/system/bamboo.service').with(
                      'content' => /^Environment="UMASK="$/
                    )
                  end
                else
                  it do
                    is_expected.to contain_file('/etc/init.d/bamboo').with(
                      'content' => /^export CATALINA_HOME=\/usr\/local\/bamboo\/atlassian-bamboo-6\.7\.1$/
                    )
                  end
                  it do
                    is_expected.to contain_file('/etc/init.d/bamboo').with(
                      'content' => /^export UMASK=$/
                    )
                  end
                end
              end

              if facts[:operatingsystem] =~ %r{debian}
                if facts[:operatingsystemmajrelease] >= '8'
                  it do
                    is_expected.to contain_file('/lib/systemd/system/bamboo.service').with(
                      'content' => /^PIDFile=\/usr\/local\/bamboo\/atlassian-bamboo-6\.7\.1\/work\/catalina\.pid$/
                    )
                  end
                  it do
                    is_expected.to contain_file('/lib/systemd/system/bamboo.service').with(
                      'content' => /^Environment="UMASK="$/
                    )
                  end
                else
                  it do
                    is_expected.to contain_file('/etc/init.d/bamboo').with(
                      'content' => /^export CATALINA_HOME=\/usr\/local\/bamboo\/atlassian-bamboo-6\.7\.1$/
                    )
                  end
                  it do
                    is_expected.to contain_file('/etc/init.d/bamboo').with(
                      'content' => /^export UMASK=$/
                    )
                  end
                end
              end
            end

            it do
              is_expected.to contain_service('bamboo').with(
                'ensure' => 'running',
                'enable' => true
              )
            end
          end

          context "bamboo::service class with custom umask" do
            let(:params) do
              {
                :umask => '0022',
              }
            end
            case facts[:osfamily]
            when 'RedHat'
              if facts[:operatingsystemmajrelease].to_i >= 7
                it do
                  is_expected.to contain_file('/usr/lib/systemd/system/bamboo.service').with(
                    'content' => /^Environment="UMASK=0022"$/
                  )
                end
              else
                it do
                  is_expected.to contain_file('/etc/init.d/bamboo').with(
                    'content' => /^export UMASK=0022$/
                  )
                end
              end
            end
          end

          context "bamboo::service class with initconfig_manage" do
            let(:params) do
              {
                :initconfig_manage => true,
                :initconfig_content => 'TEST_VAR=foo',
              }
            end

            if facts[:osfamily] == 'RedHat'
              it do
                is_expected.to contain_file('/etc/sysconfig/bamboo').with({
                  :content => /^TEST_VAR=foo$/
                }).that_notifies('Service[bamboo]')
              end
            end

            if facts[:osfamily] == 'Debian'
              it do
                is_expected.to contain_file('/etc/default/bamboo').with({
                  :content => /^TEST_VAR=foo$/
                }).that_notifies('Service[bamboo]')
              end

            end
          end
        end
      end
    end
  end
end
