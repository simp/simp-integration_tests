# == Class integration_tests::service
#
# This class is meant to be called from integration_tests.
# It ensure the service is running.
#
class integration_tests::service {
  assert_private()

  service { $::integration_tests::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true
  }
}
