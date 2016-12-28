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
end
