require 'fileutils'

$src_dir = ARGV[0] || 'pgplot'
$build_dir = ARGV[1] || 'build'

FileUtils.rm_rf $build_dir
Dir.mkdir $build_dir

drivers = File.read('drivers.conf').split(/\s+/)
=begin
drivers = %w[ GIDRIV PPDRIV PSDRIV ]
$found_lib.each do |lib|
  case lib
  when 'png'
    drivers += %w[ PNDRIV ]
  when 'X11'
    drivers += %w[ WDDRIV XWDRIV ]
    $install_files << 'pgxwin_server'
  end
end
=end

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
