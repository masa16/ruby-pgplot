require 'fileutils'

$src_dir = ARGV[0] || 'pgplot'
$build_dir = ARGV[1] || 'build'

FileUtils.rm_rf $build_dir
Dir.mkdir $build_dir

drivers = File.read('drivers.conf').split(/\s+/)

File.open(File.join($build_dir,"drivers.list"),"w") do |w|
  File.open(File.join($src_dir,"drivers.list"),"r") do |r|
    r.each_line do |l|
      l.chomp!
      drivers.each do |d|
	if /^!( #{d} .*)$/ =~ l
	  l = $1
	  break
	end
      end
      w.puts l
    end
  end
end
