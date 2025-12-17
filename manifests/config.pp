# usbguard::config
#
# @private
class usbguard::config {
  assert_private()

  $daemon_conf = @("CONTENT")
    # Managed by puppet
    AuditBackend=${usbguard::daemon_audit_backend}
    AuditFilePath=${usbguard::daemon_audit_file_path}
    AuthorizedDefault=${usbguard::daemon_authorized_default}
    DeviceRulesWithPort=${usbguard::daemon_device_rules_with_port}
    ImplicitPolicyTarget=${usbguard::daemon_implicit_policy_target}
    IPCAllowedGroups=${usbguard::daemon_ipc_allowed_groups.join(' ')}
    IPCAllowedUsers=${usbguard::daemon_ipc_allowed_users.join(' ')}
    IPCAccessControlFiles=${usbguard::daemon_ipc_access_control_files}
    PresentControllerPolicy=${usbguard::daemon_present_controller_policy}
    PresentDevicePolicy=${usbguard::daemon_present_device_policy}
    RestoreControllerDeviceState=${usbguard::daemon_restore_controller_device_state}
    RuleFile=${usbguard::daemon_rule_file}
    | CONTENT

  file { '/etc/usbguard/usbguard-daemon.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $daemon_conf,
  }

  if $usbguard::manage_rules_file {
    # unfortunately no comments allowed in the rules file (v0.7)
    # can't add header "Managed by puppet"
    concat { $usbguard::daemon_rule_file:
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
    }
  }
}
