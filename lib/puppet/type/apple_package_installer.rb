Puppet::Type.newtype(:apple_package_installer) do
  @doc = 'Installs an apple package'

  newparam(:name, namevar: true)

  ensurable

  newparam(:package) do
    desc 'Path to package on disk'
  end

  newparam(:receipt) do
    desc 'Package receipt'
  end

  newparam(:version) do
    desc 'Package version'
  end

  newparam(:installs) do
    desc 'Array of files the package installs'
    defaultto []
  end

  newparam(:checksum) do
    desc 'Array of checksums'
    defaultto []
  end

  newparam(:force_downgrade) do
    desc 'Downgrade package if a newer version is already installed'
    defaultto :false
  end

  newparam(:force_install) do
    desc 'Force install of package no matter what the state is'
    defaultto :false
  end

  newparam(:type) do
    desc 'Package type pkg|dmg, if not specified it will parse the source url extension, if no extension exists use pkg'
  end
end
