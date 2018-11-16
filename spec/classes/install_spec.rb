require 'spec_helper'

describe 'bamboo' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'bamboo::install class with defaults' do
          let(:params) { {} }

          it do
            is_expected.to contain_file('/var/local/bamboo').with(
              owner: 'bamboo',
              group: 'bamboo',
            )
          end

          it do
            is_expected.to contain_user('bamboo').with(
              shell: '/bin/bash',
              home: '/var/local/bamboo',
              managehome: true,
            )
          end

          it { is_expected.to contain_group('bamboo') }

          it do
            is_expected.to contain_file('/usr/local/bamboo').with(
              owner: 'bamboo',
              group: 'bamboo',
            )
          end

          it do
            is_expected.to contain_file('/usr/local/bamboo/atlassian-bamboo-6.7.1').with(
              owner: 'bamboo',
              group: 'bamboo',
            )
          end

          it do
            is_expected.to contain_staging__file('atlassian-bamboo-6.7.1.tar.gz').with(
              source: 'https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-6.7.1.tar.gz',
              timeout: '1800',
            )
          end

          it do
            is_expected.to contain_staging__extract('atlassian-bamboo-6.7.1.tar.gz').with(
              target: '/usr/local/bamboo/atlassian-bamboo-6.7.1',
              creates: '/usr/local/bamboo/atlassian-bamboo-6.7.1/conf',
              user: 'bamboo',
              group: 'bamboo',
            )
          end

          it do
            is_expected.to contain_file('/var/local/bamboo/logs').with(
              owner: 'bamboo',
              group: 'bamboo',
            )
          end

          it do
            is_expected.to contain_exec('chown_/usr/local/bamboo/atlassian-bamboo-6.7.1').with(
              command: 'chown -R bamboo:bamboo /usr/local/bamboo/atlassian-bamboo-6.7.1',
            )
          end
        end
      end
    end
  end
end
