# Ensures an Apple package is installed
define apple_package (
  String $source,
  String $receipt,
  String $version,
  String $ensure = 'present',
  Array $installs = [],
  Array $checksum = [],
  Boolean $force_install = false,
  Boolean $downgrade = false
) {

  $package_location = "${facts['puppet_vardir']}/packages/${title}.pkg"

  if ! defined(File["${facts['puppet_vardir']}/packages"]) {
    file { "${facts['puppet_vardir']}/packages":
      ensure => directory,
    }
  }

  notify{$downgrade:}

  file { $package_location:
    ensure  => file,
    source  => $source,
    mode    => '0644',
    backup  => false,
    require => File["${facts['puppet_vardir']}/packages"],
  }

  apple_package_installer {"${title}":
    ensure        => $ensure,
    package       => $package_location,
    receipt       => $receipt,
    version       => $version,
    installs      => $installs,
    checksum      => $checksum,
    force_install => $force_install,
    downgrade     => $downgrade,
  }
}
