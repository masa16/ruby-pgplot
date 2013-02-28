require 'uri'
require 'net/ftp'
require 'fileutils'

puts "
--------------- build-pgplot.rb ---------------
"

uri = URI.parse("ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot5.2.tar.gz")
tar_file = File.basename(uri.path)

$install_file_dir ||= File.join(Dir.pwd,'../pgplot')
$install_lib_dir ||= Dir.pwd
$top_dir = 'build_pgplot'
$src_dir = 'pgplot'
$build_dir = 'build'
$install_files = %w[grfont.dat rgb.txt]

if !$found_lib
  require 'mkmf'
  $found_lib = []
  if have_library("png","png_create_write_struct")
    $found_lib << 'png'
  end
  if have_library("X11", "XOpenDisplay")
    $found_lib << 'X11'
  end
end

case RUBY_PLATFORM
when /linux/
  os='linux'
when /cygwin/
  os='cygwin'
when /freebsd/
  os='freebsd'
when /bsd/
  os='bsd'
when /sparc-solaris/
  os='sol2'
when /x86-solaris/
  os='solx86'
else
  raise "RUBY_PLATFORM=#{RUBY_PLATFORM}: not supported"
end
puts "Platform = "+os

def find_cmd(a)
  a.each do |cmd|
    if system("which #{cmd}")
      return cmd
    end
  end
  raise "No FORTRAN compiler found in: [#{a.join(' ')}]"
end

fc = find_cmd %w[gfortran g77]
puts "FORTRAN compiler = "+fc

def run(cmd)
  puts
  puts cmd+' ...'
  system cmd
end


FileUtils.mkdir_p $top_dir
puts "Entering dir `#{$top_dir}'"
Dir.chdir $top_dir

if !File.exist?(tar_file)
  Net::FTP.open(uri.host) do |ftp|
    ftp.login
    ftp.passive = true
    puts "downloading #{tar_file} ..."
    ftp.getbinaryfile(uri.path, tar_file, 1024)
  end
end

run "gunzip -c #{tar_file} | tar xf -"

puts "rm -rf #{$build_dir} ..."
FileUtils.rm_rf $build_dir
Dir.mkdir $build_dir

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


Dir.chdir $build_dir do
   run "../#{$src_dir}/makemake ../#{$src_dir} #{os} g77_gcc"

   if fc=='gfortran'
     File.rename "makefile", "makefile.orig"
     File.open("makefile","w") do |w|
       File.open("makefile.orig","r") do |r|
         r.each_line do |l|
   	l.chomp!
   	l.sub!(/g77/,"gfortran")
   	if /^pndriv\.o : / !~ l
   	  w.puts l
   	end
         end
       end
     end
   end

  run "make all cpg"
end

%w[cpgplot.h libcpgplot.a libpgplot.a].each do |f|
  FileUtils.cp File.join($build_dir,f), $install_lib_dir
end

#FileUtils.mkdir_p $install_file_dir
#$install_files.each do |f|
#  FileUtils.cp File.join($build_dir,f), $install_file_dir
#end

Dir.chdir '..'
