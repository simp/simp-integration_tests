# == Class integration_tests::install
#
# This class is called from integration_tests for install.
#
class integration_tests::install {
  assert_private()

  package { $::integration_tests::package_name:
    ensure => present
  }
}
