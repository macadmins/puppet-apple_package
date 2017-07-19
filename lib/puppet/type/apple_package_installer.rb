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
  end

  newparam(:checksum) do
    desc 'Array of checksums'
  end

  newparam(:force_install) do
    desc 'Force install of package no matter what the state is'
  end

  newparam(:downgrade, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'Downgrade package if a newer version is already installed'
  end
end
