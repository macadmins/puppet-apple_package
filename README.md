# puppet-apple_package

This Puppet module provides a better method to install packages for macOS than the built in method. It is designed to operate more like Munki (ensuring files are present etc) It performs the following:

* Verifies that the specified package receipt is present.
* Verifies that the specified version is installed.
* If passed an array of files to verify, it will reinstall the package if any of the files are missing (optional).
* If passed an array of SHA1 checksums, it will reinstall the package if any of the files specified have a different checksum (optional).

## Example

``` puppet
node default {
  $munkitools_version = '2.8.2.2855'
  apple_package {'munkitools':
    source   => "puppet:///modules/bigfiles/munki/munkitools-${munkitools_version}.pkg",
    version  => $munkitools_version,
    receipt  => 'com.googlecode.munki.core',
    installs => ['/Applications/Managed Software Center.app/Contents/MacOS/Managed Software Center', '/usr/local/munki/managedsoftwareupdate'],
    checksum => ['f01ff7cc2b0ed727980f43990424a9124a487285', '768c21b2b89dfd6af8524e5ba4cb67b8c32e5d98'],
    # WARNING - this will cause the package to install every run, be clever when you use this
    force_install => true
  }
}
```

## Dependencies

* [puppetlabs-stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)

## Notes

The package is stored on disk, so it is recommende that this is only used for small packages (use Munki for user facing software).

## Todo

* Remove the package