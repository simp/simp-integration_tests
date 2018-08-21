require 'spec_helper'

describe 'integration_tests' do
  shared_examples_for "a structured module" do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to create_class('integration_tests') }
    it { is_expected.to contain_class('integration_tests') }
    it { is_expected.to contain_class('integration_tests::install').that_comes_before('Class[integration_tests::config]') }
    it { is_expected.to contain_class('integration_tests::config') }
    it { is_expected.to contain_class('integration_tests::service').that_subscribes_to('Class[integration_tests::config]') }

    it { is_expected.to contain_service('integration_tests') }
    it { is_expected.to contain_package('integration_tests').with_ensure('present') }
  end

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "integration_tests class without any parameters" do
          let(:params) {{ }}
          it_behaves_like "a structured module"
          it { is_expected.to contain_class('integration_tests').with_trusted_nets(['127.0.0.1/32']) }
        end

        context "integration_tests class with firewall enabled" do
          let(:params) {{
            :enable_firewall => true
          }}

          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('integration_tests::config::firewall') }

          it { is_expected.to contain_class('integration_tests::config::firewall').that_comes_before('Class[integration_tests::service]') }
          it { is_expected.to create_iptables__listen__tcp_stateful('allow_integration_tests_tcp_connections').with_dports(9999)
          }
        end

        context "integration_tests class with selinux enabled" do
          let(:params) {{
            :enable_selinux => true
          }}

          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('integration_tests::config::selinux') }
          it { is_expected.to contain_class('integration_tests::config::selinux').that_comes_before('Class[integration_tests::service]') }
          it { is_expected.to create_notify('FIXME: selinux') }
        end

        context "integration_tests class with auditing enabled" do
          let(:params) {{
            :enable_auditing => true
          }}

          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('integration_tests::config::auditing') }
          it { is_expected.to contain_class('integration_tests::config::auditing').that_comes_before('Class[integration_tests::service]') }
          it { is_expected.to create_notify('FIXME: auditing') }
        end

        context "integration_tests class with logging enabled" do
          let(:params) {{
            :enable_logging => true
          }}

          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('integration_tests::config::logging') }
          it { is_expected.to contain_class('integration_tests::config::logging').that_comes_before('Class[integration_tests::service]') }
          it { is_expected.to create_notify('FIXME: logging') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'integration_tests class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta'
      }}

      it { expect { is_expected.to contain_package('integration_tests') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
