require "mkmf"

def main
  extconf_start
  check_narray

  $objs = %w(rb_pgplot.o kwarg.o)
  $enable_autobuild = enable_config('autobuild', false)
  $found_lib = []

  # Check PGPLOT Header
  if have_header("cpgplot.h")
    if have_library("cpgplot","cpgbeg")
      create_makefile("pgplot")
      exit
    end

    # Check for extra libs then re-check for PGPLOT library
    puts "First check for PGPLOT library failed."
    check_extra_libs
    $libs = append_library($libs, "pgplot")

    if have_library("cpgplot","cpgbeg")
      create_makefile("pgplot")
      exit
    end
  elsif $enable_autobuild
    check_extra_libs
  end

  if $enable_autobuild
    autobuild_pgplot
  else
    puts "
The PGPLOT library was not found.  To auto-build PGPLOT library
as part of installing Ruby/PGPLOT, pass the --enable-autobuild option.

Examples:
       Gem install:  gem install pgplot -- --enable-autobuild
    Manual install:  ruby extconf.rb --enable-autobuild

"
  end
end


def extconf_start
  # configure options:
  #  --with-pgplot-dir=path
  #  --with-pgplot-include=path
  #  --with-pgplot-lib=path
  dir_config("pgplot")

  # configure options:
  #  --with-x11-dir=path
  #  --with-x11-include=path
  #  --with-x11-lib=path
  dir_config("x11")

  # Otherwise you can also specify:
  #  --with-opt-dir=path
  #  --with-opt-include=path
  #  --with-opt-lib=path
end

def find_narray_h
  $LOAD_PATH.each do |x|
    p x
    if File.exist? File.join(x,'narray.h')
      $INCFLAGS = "-I#{x} " + $INCFLAGS
      break
    end
  end
end

def find_libnarray_a
  $LOAD_PATH.each do |x|
    if File.exist? File.join(x,'libnarray.a')
      $LDFLAGS = "-L#{x} " + $LDFLAGS
      break
    end
  end
end

def check_narray
  require "narray"
  find_narray_h
  if !have_header("narray.h")
    puts "
  Header numo/narray.h was not found. Give pathname as follows:
  % ruby extconf.rb --with-narray-include=narray_h_dir"
    exit(1)
  end

  if RUBY_PLATFORM =~ /mswin|cygwin|mingw/
    find_libnarray_a
    unless have_library("narray","na_make_object")
      puts "libnarray.a not found"
      exit(1)
    end
  end
end


def check_extra_libs
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
end


def autobuild_pgplot
  # Exit unless a fortran compiler was found
  exit unless %w[gfortran g77].any?{|cmd| system("which #{cmd}")}
  puts "enabling auto-build PGPLOT Library..."

  $subdir = 'build_lib'
  $CFLAGS = "-I#{$subdir}/build "+$CFLAGS
  $LDFLAGS = "-L#{$subdir}/build "+$LDFLAGS
  $libs = append_library($libs, "cpgplot")
  $defs.push '-DPGPLOT_DIR=\\"$(PGPLOT_DIR)\\"'

  # Generate Makefile
  create_makefile("pgplot")

  # Append PGPLOT install task to Makefile
  exit unless $makefile_created
  puts "appending extra install tasks to Makefile"
  File.open("Makefile","a") do |w|
    w.print "
PGPLOT_DIR = $(RUBYARCHDIR)/pgplot
PGPLOT_BUILD = #{$subdir}/build

$(PGPLOT_BUILD)/libcpgplot.a:
	(cd #{$subdir}; make build/libcpgplot.a)
$(PGPLOT_BUILD)/cpgplot.h: $(PGPLOT_BUILD)/libcpgplot.a
rb_pgplot.o: $(PGPLOT_BUILD)/cpgplot.h
$(DLLIB): $(PGPLOT_BUILD)/libcpgplot.a

install: install-pgplot
install-pgplot:
	$(MAKEDIRS) $(PGPLOT_DIR)
	$(INSTALL_DATA) $(PGPLOT_BUILD)/grfont.dat $(PGPLOT_DIR)
	$(INSTALL_DATA) $(PGPLOT_BUILD)/rgb.txt $(PGPLOT_DIR)
"
    if $found_lib.include? "X11"
      w.print \
"	$(INSTALL_PROG) $(PGPLOT_BUILD)/pgxwin_server $(PGPLOT_DIR)

$(PGPLOT_BUILD)/pgxwin_server: $(PGPLOT_BUILD)/cpgplot.h
	(cd #{$subdir}; make build/pgxwin_server)
$(DLLIB): $(PGPLOT_BUILD)/pgxwin_server
"
    end
  end

  puts "creating #{$subdir}/drivers.conf"
  File.open("#{$subdir}/drivers.conf","w") do |w|
    w.puts "GIDRIV PPDRIV PSDRIV"
    w.puts "PNDRIV" if $found_lib.include? "png"
    w.puts "WDDRIV XWDRIV" if $found_lib.include? "X11"
  end

  puts "Ready to download and auto-build PGPLOT !!"
end

main
