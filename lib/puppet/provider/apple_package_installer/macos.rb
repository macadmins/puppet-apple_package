Puppet::Type.type(:apple_package_installer).provide(:macos) do
  desc 'Installs an Apple package'
  confine osfamily: 'Darwin'
  defaultfor operatingsystem: 'Darwin'

  commands installer: '/usr/sbin/installer'
  commands pkgutil: '/usr/sbin/pkgutil'

  require 'puppet/util/plist' if Puppet.features.cfpropertylist?
  require 'puppet/util/Package'
  require 'digest'

  def check_for_install(receipt, version, installs, checksum, force_install, force_downgrade)
    installed = true

    return false if force_install == true

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
    version_result = Puppet::Util::Package.versioncmp(version, installed_info['pkg-version'])
    Puppet.debug "#check_for_install versioncmp result: #{version_result}"
    Puppet.debug "#check_for)install force_downgrade: #{force_downgrade}"
    if force_downgrade == true
      return false unless version_result == 0
    else
      return false unless version_result == -1
    end

    # if installs files are given, check for presence
    installs_counter = 0
    unless installs.nil?
      installs.each do |install|
        Puppet.debug "#check_for_install install: #{install}"
        return false unless File.exist?(install)
        # if checksums are given, make sure the files match
        if checksum.length >= installs_counter && checksum != []
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
      resource[:checksum],
      resource[:force_install],
      resource[:force_downgrade]
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
