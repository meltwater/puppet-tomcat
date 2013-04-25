/*

== Class: tomcat

Installs tomcat using the default version providing by distributions.

Example usage:

  include tomcat

*/
class tomcat {
  $tomcat::tomcat_home = ''

  case $operatingsystem {
    RedHat       : { include tomcat::redhat }
    Debian,Ubuntu: { include tomcat::debian }
    default      : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }
}
