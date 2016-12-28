Puppet::Type.type(:apple_package_installer).provide(:macos) do
  desc 'Installs an Apple package'
  confine osfamily: 'Darwin'
  defaultfor operatingsystem: 'Darwin'

  commands installer: '/usr/sbin/installer'
  commands pkgutil: '/usr/sbin/pkgutil'

  require 'puppet/util/plist' if Puppet.features.cfpropertylist?
  require 'digest'

  def check_for_install(receipt, version, installs, checksum)
    installed = true
    
    # check if receipt is present at all
    installed_receipts = pkgutil(['--pkgs-plist'])
    installed_receipts = Puppet::Util::Plist.parse_plist(installed_receipts)
    Puppet.debug "#check_for_install installed_receipts: #{installed_receipts}"
    Puppet.debug "#check_for_install receipt: #{receipt}"
    return false unless installed_receipts.include?(receipt)

    # check for installed version
    installed_info = pkgutil(['--pkg-info-plist', receipt])
    installed_info = Puppet::Util::Plist.parse_plist(installed_info)
    Puppet.debug "#check_for_install installed_info: #{installed_info}"
    Puppet.debug "#check_for_install version: #{version}"
    return false unless version == installed_info['pkg-version']

    # if installs files are given, check for presence
    installs_counter = 0
    unless installs == nil
      installs.each do |install|
        Puppet.debug "#check_for_install install: #{install}"
        return false unless File.exist?(install)
        # if checksums are given, make sure the files match
        if checksum.length >= installs_counter and checksum != []
          Puppet.debug "#check_for_install checksum[installs_counter]: #{checksum[installs_counter]}"
          return false unless checksum[installs_counter] == Digest::SHA1.file(install).hexdigest
        end
        installs_counter += 1
      end
    end

    installed
  end

  def exists?
    check_for_install(
      resource[:receipt], 
      resource[:version],
      resource[:installs],
      resource[:checksum]
    ) == true
  end

  def create
    installer(
      [
        '-pkg',
        resource[:package],
        '-target',
        '/'
      ]
    )
  end

  def destroy
    # Get all the installed files from pkgutil
    # Remove all the files
  end
end
