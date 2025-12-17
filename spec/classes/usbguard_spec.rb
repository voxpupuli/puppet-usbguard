# frozen_string_literal: true

require 'spec_helper'

describe 'usbguard' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:ipc_allowed_groups) do
        case facts[:os]['family']
        when 'Debian'
          %w[root plugdev]
        else
          %w[wheel]
        end
      end

      it { is_expected.to compile.with_all_deps }

      context 'with defaults' do
        it { is_expected.to contain_class('usbguard::install').that_comes_before('Class[usbguard::config]') }
        it { is_expected.to contain_class('usbguard::config').that_notifies('Class[usbguard::service]') }
        it { is_expected.to contain_class('usbguard::service') }
        it { is_expected.to contain_package('usbguard').with_ensure('installed') }
        it { is_expected.to contain_service('usbguard').with_ensure('running').with_enable(true) }

        it do
          is_expected.to contain_file('/etc/usbguard/usbguard-daemon.conf').
            with_ensure('file').
            with_owner('root').
            with_group('root').
            with_mode('0600').
            with_content(<<~CONFIG)
              # Managed by puppet
              AuditBackend=FileAudit
              AuditFilePath=/var/log/usbguard/usbguard-audit.log
              AuthorizedDefault=none
              DeviceRulesWithPort=false
              ImplicitPolicyTarget=block
              IPCAllowedGroups=#{ipc_allowed_groups.join(' ')}
              IPCAllowedUsers=root
              IPCAccessControlFiles=/etc/usbguard/IPCAccessControl.d/
              PresentControllerPolicy=keep
              PresentDevicePolicy=apply-policy
              RestoreControllerDeviceState=false
              RuleFile=/etc/usbguard/rules-managed-by-puppet.conf
            CONFIG
        end

        it do
          is_expected.to contain_concat('/etc/usbguard/rules-managed-by-puppet.conf').
            with_ensure('present').
            with_owner('root').
            with_group('root').
            with_mode('0600')
        end
      end
    end
  end
end
