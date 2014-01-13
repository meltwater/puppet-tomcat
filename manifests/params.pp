class tomcat::params {

  $default_source_release = "6.0.26"
  $default_source_release_v55 = "5.5.27"
  $default_source_release_v7 = "7.0.50"

  $instance_basedir = "/srv/tomcat"

  if $tomcat_mirror {
    $mirror = $tomcat_mirror
  } else {
    $mirror = "http://archive.apache.org/dist/tomcat/"
  }

  if defined(Class["Tomcat::source"]) {
    $type = "source"
    if ( ! $tomcat::source::tomcat_version ) {
      $maj_version = "6"
      $version = $default_source_release
    } else {
      $version = $tomcat::source::tomcat_version
      if versioncmp($tomcat::source::tomcat_version, '7.0.0') >= 0 {
        $maj_version = "7"
      }
      elsif versioncmp($tomcat::source::tomcat_version, '6.0.0') >= 0 {
        $maj_version = "6"
      }
      elsif versioncmp($tomcat::source::tomcat_version, '5.5.0') >= 0 {
        $maj_version = "5.5"
      }
      else {
        fail "only versions >= 5.5 or >= 6.0 are supported !"
      }
    }
  } else {
    $type = "package"
    if $tomcat::source::tomcat_version { notify {"\$tomcat::source::tomcat_version is not useful when using distribution package!":} }
    $maj_version = $::operatingsystem ? {
      "Debian" => $lsbdistcodename ? {
        /lenny|squeeze/ => "6",
      },
      "RedHat" => $lsbdistcodename ? {
        "Tikanga"  => "5.5",
        "Santiago" => "6",
      }
    }

    # it would be better to set the distribution tomcat-version!
    $version = $maj_version ? {
      "5.5" => $default_source_release_v55,
      "6"   => $default_source_release,
    }

  }

  if $tomcat_debug {
    notify{"type=${type},maj_version=${maj_version},version=${version}":}
  }

  if defined(Class["Tomcat::source"]) {
    $tomcat_home = "/opt/apache-tomcat-${version}"
  } else {
    case $::operatingsystem {
      RedHat       : { $tomcat_home = '/var/lib/tomcat5' }
      Debian,Ubuntu: { $tomcat_home = '/usr/share/tomcat6' }
    }
  }


}
