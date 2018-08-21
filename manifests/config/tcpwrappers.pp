# == Class integration_tests::config::tcpwrappers
#
# This class is meant to be called from integration_tests.
# It ensures that tcpwrappers rules are defined.
#
class integration_tests::config::tcpwrappers {
  assert_private()

  # FIXME: ensure your module's tcpwrappers settings are defined here.
  $msg = "FIXME: define the ${module_name} module's tcpwrappers settings."

  notify{ 'FIXME: tcpwrappers': message => $msg } # FIXME: remove this, add logic
  err( $msg )                                     # FIXME: remove this, add logic

}

