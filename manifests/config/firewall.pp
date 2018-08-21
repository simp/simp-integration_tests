# == Class integration_tests::config::firewall
#
# This class is meant to be called from integration_tests.
# It ensures that firewall rules are defined.
#
class integration_tests::config::firewall {
  assert_private()

  # FIXME: ensure your module's firewall settings are defined here.
  iptables::listen::tcp_stateful { 'allow_integration_tests_tcp_connections':
    trusted_nets => $::integration_tests::trusted_nets,
    dports       => $::integration_tests::tcp_listen_port
  }
}
