# Ensures an Apple package is installed
define apple_package (
  String $source,
  String $receipt,
  String $version,
  String $ensure = 'present',
  Array $installs = [],
  Array $checksum = [],
  Boolean $force_install = false,
  Boolean $force_downgrade = false,
  String $http_checksum = '',
  String $http_checksum_type = 'sha256',
  String $http_username = '',
  String $http_password = ''
) {

  $package_location = "${facts['puppet_vardir']}/packages/${title}.pkg"

  if ! defined(File["${facts['puppet_vardir']}/packages"]) {
    file { "${facts['puppet_vardir']}/packages":
      ensure => directory,
    }
  }

  if 'puppet:///' in $source {
    $remote_package = false
  } else {
    $remote_package = true
  }

  if $remote_package {
    if $http_username != '' and $http_password != '' {
      $http_attributes = {
        'username' => $http_username,
        'password' => $http_password,
      }
    } else {
      $http_attributes = {}
    }

    remote_file { $package_location:
      ensure        => present,
      source        => $source,
      checksum      => $http_checksum,
      checksum_type => $http_checksum_type,
      *             => $http_attributes,
    }
  } else {
    file { $package_location:
        ensure  => file,
        source  => $source,
        mode    => '0644',
        backup  => false,
        require => File["${facts['puppet_vardir']}/packages"],
      }
  }

  apple_package_installer {$title:
    ensure          => $ensure,
    package         => $package_location,
    receipt         => $receipt,
    version         => $version,
    installs        => $installs,
    checksum        => $checksum,
    force_install   => $force_install,
    force_downgrade => $force_downgrade,
  }
}
