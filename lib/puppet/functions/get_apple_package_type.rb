Puppet::Functions.create_function(:'get_apple_package_type') do
  dispatch :default_impl do
    param 'String', :url
    return_type 'String'
  end

  def default_impl(url)
    ext = File.extname(URI.parse(url).path).gsub('.', '')
    # parse url file extension, if no extension use pkg
    ext.empty? ? 'pkg' : ext
  end
end
