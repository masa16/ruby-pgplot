$src_dir = ARGV[0] || 'pgplot'
$build_dir = ARGV[1] || 'build'

case RUBY_PLATFORM
when /-linux$/
  os='linux'
when /-cygwin$/
  os='cygwin'
when /-freebsd$/
  os='freebsd'
when /-bsd$/
  os='bsd'
when /sparc-solaris$/
  os='sol2'
when /x86-solaris$/
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
puts

Dir.chdir $build_dir do
  cmd="../#{$src_dir}/makemake ../#{$src_dir} #{os} g77_gcc"
  puts cmd+' ...'
  s=system cmd
  raise "failed: #{cmd}" if !s

  File.rename "makefile", "makefile.orig"
  File.open("makefile","w") do |w|
    File.open("makefile.orig","r") do |r|
      r.each_line do |l|
   	l.chomp!
   	l.sub!(/g77/,"gfortran") if fc=='gfortran'
   	if /^pndriv\.o : / !~ l
   	  w.puts l
   	end
      end
    end
  end
end
