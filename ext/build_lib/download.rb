require 'uri'
require 'net/ftp'

pkg_uri = ARGV[0] || "ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot5.2.tar.gz"

uri = URI.parse(pkg_uri)
tar_file = File.basename(uri.path)

Net::FTP.open(uri.host) do |ftp|
  ftp.login
  ftp.passive = true
  puts "downloading #{tar_file} ..."
  ftp.getbinaryfile(uri.path, tar_file, 1024)
end
