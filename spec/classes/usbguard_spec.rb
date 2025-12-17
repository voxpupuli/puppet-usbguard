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

      it { is_expected.to contain_class('usbguard::install').that_comes_before('Class[usbguard::config]') }
      it { is_expected.to contain_class('usbguard::config').that_notifies('Class[usbguard::service]') }
      it { is_expected.to contain_class('usbguard::service') }

      context 'with defaults' do
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

        it { is_expected.to have_usbguard__rule_resource_count(0) }
      end

      context 'with non-default params' do
        let(:params) do
          {
            package_ensure: '42',
            package_name: 'usbguard42',
            service_name: 'usbguard42',
            service_ensure: 'stopped',
            daemon_audit_backend: 'LinuxAudit',
            daemon_audit_file_path: '/tmp/usbguard-audit.log',
            daemon_authorized_default: 'all',
            daemon_device_rules_with_port: true,
            daemon_implicit_policy_target: 'allow',
            daemon_ipc_allowed_groups: %w[group1 group2],
            daemon_ipc_allowed_users: %w[user1 user2],
            daemon_ipc_access_control_files: '/custom/path/',
            daemon_present_controller_policy: 'apply-policy',
            daemon_present_device_policy: 'block',
            daemon_restore_controller_device_state: true,
            daemon_rule_file: '/tmp/rules.conf',
          }
        end

        it { is_expected.to contain_package('usbguard42').with_ensure('42') }
        it { is_expected.to contain_service('usbguard42').with_ensure('stopped').with_enable(false) }

        it do
          is_expected.to contain_file('/etc/usbguard/usbguard-daemon.conf').
            with_content(<<~CONFIG)
              # Managed by puppet
              AuditBackend=LinuxAudit
              AuditFilePath=/tmp/usbguard-audit.log
              AuthorizedDefault=all
              DeviceRulesWithPort=true
              ImplicitPolicyTarget=allow
              IPCAllowedGroups=group1 group2
              IPCAllowedUsers=user1 user2
              IPCAccessControlFiles=/custom/path/
              PresentControllerPolicy=apply-policy
              PresentDevicePolicy=block
              RestoreControllerDeviceState=true
              RuleFile=/tmp/rules.conf
            CONFIG
        end

        it { is_expected.to have_usbguard__rule_resource_count(0) }
      end

      context 'not managing service, package, and rules file' do
        let(:params) do
          {
            manage_service: false,
            manage_package: false,
            manage_rules_file: false,
          }
        end

        it { is_expected.not_to contain_service('usbguard') }
        it { is_expected.not_to contain_package('usbguard') }
        it { is_expected.not_to contain_concat('/etc/usbguard/rules-managed-by-puppet.conf') }
      end
    end
  end
end
