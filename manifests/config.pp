# usbguard::config
#
# @private
class usbguard::config {
  assert_private()

  $ipc_allowed_users = join($usbguard::daemon_ipc_allowed_users, ' ')
  $ipc_allowed_groups= join($usbguard::daemon_ipc_allowed_groups, ' ')

  $daemon_conf = @("CONTENT")
    # Managed by puppet
    AuditFilePath=${usbguard::daemon_audit_file_path}
    DeviceRulesWithPort=${usbguard::daemon_device_rules_with_port}
    ImplicitPolicyTarget=${usbguard::daemon_implicit_policy_target}
    IPCAllowedGroups=${ipc_allowed_groups}
    IPCAllowedUsers=${ipc_allowed_users}
    PresentControllerPolicy=${usbguard::daemon_present_controller_policy}
    PresentDevicePolicy=${usbguard::daemon_present_device_policy}
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
