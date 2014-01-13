# == Class: tomcat::source
# 
# Installs tomcat 5.5.X, 6.0.X or 7.0.X using the compressed archive from your favorite tomcat
# mirror. Files from the archive will be installed in /opt/apache-tomcat/.
# 
# Class variables:
# - *$log4j_conffile*: see tomcat
# 
# Requires:
# - java to be previously installed
# - archive definition (from puppet camptocamp/puppet-archive module)
# - Package["curl"]
# 
# Tested on:
# - RHEL 5,6
# - Debian Lenny/Squeeze
# - Ubuntu Lucid
# 
# Usage:
#   class { 'tomcat::source': tomcat_version => "7.0.50" }
#
class tomcat::source($tomcat_version = "6.0.26") inherits tomcat::base {

  include tomcat::params

  case $::operatingsystem {
    RedHat,CentOS: {
      package { ["log4j", "jakarta-commons-logging"]: ensure => present }
    }
    Debian,Ubuntu: {
      package { ["liblog4j1.2-java", "libcommons-logging-java"]: ensure => present }
    }
  }

  $tomcat_home = "/opt/apache-tomcat-${tomcat::params::version}"


  if $tomcat::params::maj_version == "6" {
    # install extra tomcat juli adapters, used to configure logging.
    # include tomcat::juli
  }


  $baseurl = $tomcat::params::maj_version ? {
    "5.5"   => "${tomcat::params::mirror}/tomcat-5/v${tomcat::params::version}/bin",
    default => "${tomcat::params::mirror}/tomcat-${tomcat::params::maj_version}/v${tomcat::params::version}/bin",
  }
  
  $tomcaturl = "${baseurl}/apache-tomcat-${tomcat::params::version}.tar.gz"
  
  # link logging libraries from java
  include tomcat::logging

  archive{ "apache-tomcat-${tomcat::params::version}":
    url         => "$tomcaturl",
    digest_url  => "${tomcaturl}.md5",
    digest_type => "md5",
    target      => "/opt",
  }

  file {"/opt/apache-tomcat":
    ensure  => link,
    target  => $tomcat_home,
    require => Archive["apache-tomcat-${tomcat::params::version}"],
    before  => [File["commons-logging.jar"], File["log4j.jar"], File["log4j.properties"]],
  }

  file { $tomcat_home:
    ensure  => directory,
    require => Archive["apache-tomcat-${tomcat::params::version}"],
  }

    # Workarounds
  case $tomcat::params::version {
    "6.0.18": {
      # Fix https://issues.apache.org/bugzilla/show_bug.cgi?id=45585
      file {"${tomcat_home}/bin/catalina.sh":
        ensure  => present,
        source  => "puppet:///modules/tomcat/catalina.sh-6.0.18",
        require => Archive["apache-tomcat-${tomcat::params::version}"],
        mode => "755",
      }
    }

    "7.0.50": {
      # Fix https://issues.apache.org/bugzilla/show_bug.cgi?id=45585
      file {"${tomcat_home}/bin/catalina.sh":
        ensure  => present,
        source  => "puppet:///modules/tomcat/catalina.sh-7.0.50",
        require => Archive["apache-tomcat-${tomcat::params::version}"],
        mode => "755",
      }
    }
  }

}
