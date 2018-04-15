require 'fileutils'

$src_dir = ARGV[0] || 'pgplot'

fnw = File.join($src_dir,"drivers/pndriv.c")
fnr = fnw + ".orig"

FileUtils.mv(fnw,fnr)

open(fnr,"rt") do |r|
  open(fnw,"wt") do |w|
    while s = r.gets
      w.print s.sub(/png_ptr->jmpbuf/,"png_jmpbuf(png_ptr)")
    end
  end
end
