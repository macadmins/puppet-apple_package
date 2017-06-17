node default {
  $munkitools_version = '2.8.2.2855'
  apple_package {'munkitools':
    source        => "puppet:///modules/bigfiles/munki/munkitools-${munkitools_version}.pkg",
    version       => $munkitools_version,
    receipt       => 'com.googlecode.munki.core',
    installs      => ['/Applications/Managed Software Center.app/Contents/MacOS/Managed Software Center', '/usr/local/munki/managedsoftwareupdate'],
    checksum      => ['f01ff7cc2b0ed727980f43990424a9124a487285', '768c21b2b89dfd6af8524e5ba4cb67b8c32e5d98'],
    force_install => false
  }
}
