Puppet::Type.type(:apple_package_installer).provide(:macos) do
  desc 'Installs an Apple package'
  confine osfamily: 'Darwin'
  defaultfor operatingsystem: 'Darwin'

  commands installer: '/usr/sbin/installer'
  commands pkgutil: '/usr/sbin/pkgutil'
  commands hdiutil: '/usr/bin/hdiutil'

  require 'puppet/util/plist' if Puppet.features.cfpropertylist?
  require 'puppet/util/package'
  require 'digest'
  require 'securerandom'

  def check_for_install(receipt, version, installs, checksum, force_install, force_downgrade, type)
    installed = true

    return false if force_install == true

    installed_version = ''

    Puppet.debug "#check for type: #{type}"
    if type == 'dmg'
      # find out if the application has been installed and get the version
      Dir.entries('/Applications').each do |app|
        plist_path = '/Applications/'+app+'/Contents/Info.plist'

        next unless File.exist? plist_path

        app_info = Puppet::Util::Plist.read_plist_file(plist_path)
        bundle_identifer = app_info['CFBundleIdentifier']
        bundle_version = app_info['CFBundleShortVersionString']

        Puppet.debug "#check installed package: #{bundle_identifer}, #{bundle_version}"
        if bundle_identifer == receipt
          Puppet.debug "#found target package."
          installed_version = bundle_version
          break
        end
      end
      return false if installed_version.empty?
    else
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
      installed_version = installed_info['pkg-version']
    end

    Puppet.debug "#check_for_install version: #{version}"
    version_result = Puppet::Util::Package.versioncmp(version, installed_version)
    Puppet.debug "#check_for_install versioncmp result: #{version_result}"
    Puppet.debug "#check_for_install force_downgrade: #{force_downgrade}"
    if force_downgrade == true
      return false unless version_result == 0
    else
      return false if version_result == 1
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
    Puppet.debug "#check_for_install final installed value #{installed}"
    installed
  end

  def exists?
    check_for_install(
      resource[:receipt],
      resource[:version],
      resource[:installs],
      resource[:checksum],
      resource[:force_install],
      resource[:force_downgrade],
      resource[:type],
    ) == true
  end

  def create
    package = resource[:package]
    type = resource[:type]
    if type == "dmg"
      Puppet.debug "#install dmg: #{package}"
      install_dmg package
    else
      Puppet.debug "#install pkg: #{package}"
      install_pkg package
    end
  end

  def install_pkg(package)
    installer(
      [
        '-pkg',
        package,
        '-target',
        '/'
      ]
    )
  end

  def install_dmg(package)
    filename = SecureRandom.hex(10)
    tmp_file =  '/tmp/'+filename
    tmp_file_cdr = tmp_file + ".cdr"
    mount_point = '/tmp/puppet-apple-package'

    # convert for the dmg file contained a EULA
    # it will output a file with suffix '.cdr'
    Puppet.debug "#convert dmg file: #{package}"
    convert_dmg(package, tmp_file)

    # attach dmg file
    Puppet.debug "#attach dmg file: #{mount_point}, #{tmp_file_cdr}"
    attach_dmg(mount_point, tmp_file_cdr)

    # copy app file to /Applications folder
    apps = Dir.entries(mount_point).select {|f| f.end_with?('.app') }
    unless apps.empty?
      app = mount_point + '/' + apps[0]
      Puppet.debug "#found app and install: #{app}"
      FileUtils.cp_r app, '/Applications'
    end

    # deach volume
    Puppet.debug "#detach dmg file: #{mount_point}"
    detach_dmg(mount_point)

    # clear tmp file
    Puppet.debug "#clear tmp file: #{tmp_file_cdr}"
    if File.exist? tmp_file_cdr
      File.delete tmp_file_cdr
    end
  end

  def convert_dmg(package, file)
    hdiutil(
      [
        'convert',
        '-quiet',
        package,
        '-format',
        'UDTO',
        '-o',
        file
      ]
    )
  end

  def attach_dmg(mount_point, file)
    hdiutil(
      [
        'attach',
        '-quiet',
        '-nobrowse',
        '-noverify',
        '-noautoopen',
        '-mountpoint',
        mount_point,
        file
      ]
    )
  end

  def detach_dmg(mount_point)
    hdiutil(
      [
        'detach',
        mount_point
      ]
    )
  end

  def destroy
    # Get all the installed files from pkgutil
    # Remove all the files
  end
end
