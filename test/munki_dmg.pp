node default {
  apple_package {'JSON-Viewer':
    source          => "puppet:///modules/bigfiles/JSON-Viewer.dmg",
    version         => '1.2.2',
    receipt         => 'com.pascalgiguere.JSON-Viewer',
  #  checksum        => ['eeb39692b214f3604e7fc344ec7b822c7934897050cc7bbd1bedb7287c259670'],
    force_install   => false,
 #   force_downgrade => true,
    type            => 'dmg',
  }
}
