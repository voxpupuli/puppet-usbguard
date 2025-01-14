# usbguard::install
#
# @private
#
# @summary Install the usbguard package
#
# @example
#   private class - don't use it directly
class usbguard::install {
  assert_private()

  if $usbguard::manage_package {
    package { $usbguard::package_name:
      ensure => $usbguard::package_ensure,
    }
  }
}
