# extconf.rb : Configure script for Ruby/PGPLOT
#
#   Copyright (c) 2000,2001 Masahiro TANAKA <masa@ir.isas.ac.jp>
#
#   This program is free software.
#   You can distribute/modify this program
#   under the same terms as Ruby itself.
#   NO WARRANTY.
#
# usage: ruby extconf.rb [configure options]

# Narray is now Gem based, so require rubygems
# so that we can use Gem class to find narray.
require "mkmf"

#$DEBUG = true

# configure options:
#  --with-x11-dir=path
#  --with-x11-include=path
#  --with-x11-lib=path
dir_config("x11")

# configure options:
#  --with-pgplot-dir=path
#  --with-pgplot-include=path
#  --with-pgplot-lib=path
dir_config("pgplot")

# Otherwise you can also specify:
#  --with-opt-dir=path
#  --with-opt-include=path
#  --with-opt-lib=path

def find_dir_w_file(d,h)
  g = Dir.glob(RbConfig.expand(d+"/"+h))
  File.dirname(g.last) if g and !g.empty?
end

def find_dir_in_gemspec
  begin
    require 'rubygems'
    if gemspec=Gem::Specification.find_by_path('narray')
      return File.join(gemspec.full_gem_path, gemspec.require_path)
    end
  rescue
  end
  nil
end

# Check NArray
gems_dir="$(rubylibprefix)/gems/$(ruby_version)/gems/"
narray_d="narray-0.[56].*"
narray_h="narray.h"
if narray_h_dir =
    find_dir_in_gemspec ||
    find_dir_w_file("../"+narray_d,narray_h) ||
    find_dir_w_file(gems_dir+narray_d,narray_h) ||
    find_dir_w_file(CONFIG['sitearchdir'],narray_h) ||
    find_dir_w_file(CONFIG['archdir'],narray_h)
  $CPPFLAGS = " -I#{narray_h_dir} " + $CPPFLAGS
end
exit unless have_header("narray.h")

if RUBY_PLATFORM =~ /cygwin|mingw/
  $LDFLAGS = " -L#{CONFIG['sitearchdir']} "+$LDFLAGS
  exit unless have_library("narray","na_make_object")
end

# Check FORTRAN Libraries
#
# SUN WorkShop FORTRAN 77 compiler ver5.0
# configure options: --with-sunws
if with_config("sunws")
  $libs = "-lM77 -lsunmath "+$libs
  exit unless find_library("F77", "f77_init", "/opt/SUNWspro/lib")
  $defs.push "-DSPARC_FORTRAN"
#
# GNU FORTRAN v4
elsif have_library("gfortran")
  $CFLAGS = "-Wall "+$CFLAGS
  $defs.push "-DGNU_FORTRAN"
#
# GNU FORTRAN v3
elsif have_library("g77")
  $CFLAGS = "-Wall "+$CFLAGS
  $defs.push "-DGNU_FORTRAN"
else
  puts "failed"
  exit
end

# Check GrWin Library (for cygwin (and mingw32?))
#  configure options: --with-grwin
if with_config("grwin")
  #$LDFLAGS = "-Wl,--subsystem,console "+$LDFLAGS
  if RUBY_PLATFORM =~ /cygwin|mingw/
    $libs += " -mwindows"
  end
  exit unless have_library("GrWin", "GWinit")
end

$found_lib = []

# Check X11 Library
if have_library("X11", "XOpenDisplay")
  $found_lib << 'X11'
end

# Check PNG Library
libs_save = $libs
$libs = append_library($libs, "z")
if have_library("png","png_create_write_struct")
  $found_lib << 'png'
else
  $libs = libs_save
end

$libs = append_library($libs, "pgplot")
$have_pgplot = false

# Check PGPLOT Header
if have_header("cpgplot.h")

  # Check PGPLOT Library
  if find_library("cpgplot","cpgbeg", "/usr/lib",
		  "/usr/local/lib", "/usr/local/pgplot" )
    $have_pgplot = true
  end
end

if !$have_pgplot
  #$CPPFLAGS = " -I. "+$CPPFLAGS
  #$LDFLAGS = " -L. "+$LDFLAGS
  begin
    load './build-pgplot.rb'
    if have_header("cpgplot.h")
      if have_library("cpgplot","cpgbeg")
	$have_pgplot = true
      end
    end
    $pgplot_built = true
    $defs.push '-DPGPLOT_DIR=\\"$(PGPLOT_DIR)\\"'
  rescue => e
    puts
    puts e.message
    puts e.backtrace
    STDERR.print "\n**** Automatic build of PGPLOT library is failed ****\n\n"
  end
end

exit unless $have_pgplot

$objs = %w(rb_pgplot.o kwarg.o)

# Generate Makefile
create_makefile("pgplot")

# Append PGPLOT install task to Makefile
if $makefile_created && $pgplot_built
  puts "appending extra install task to Makefile"
  File.open("Makefile","a") do |w|
    w.print <<EOL

install: install-pgplot
PGPLOT_BUILDDIR = build_pgplot/build
PGPLOT_DIR = $(RUBYARCHDIR)/pgplot
install-pgplot:
	$(MAKEDIRS) $(PGPLOT_DIR)
	$(INSTALL_DATA) $(PGPLOT_BUILDDIR)/grfont.dat $(PGPLOT_DIR)
	$(INSTALL_DATA) $(PGPLOT_BUILDDIR)/rgb.txt $(PGPLOT_DIR)
EOL
    if $found_lib.include? "X11"
      w.print <<EOL
	$(INSTALL_PROG) $(PGPLOT_BUILDDIR)/pgxwin_server $(PGPLOT_DIR)
EOL
    end
  end
end
