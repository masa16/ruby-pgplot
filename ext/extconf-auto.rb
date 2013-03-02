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

load "./extconf.rb"

exit if $have_pgplot

puts "enabling auto-build PGPLOT Library..."

$subdir = 'build_lib'

$CFLAGS = "-I#{$subdir}/build "+$CFLAGS
$LDFLAGS = "-L#{$subdir}/build "+$LDFLAGS

$libs = append_library($libs, "pgplot")
$libs = append_library($libs, "cpgplot")
$defs.push '-DPGPLOT_DIR=\\"$(PGPLOT_DIR)\\"'

# Generate Makefile
create_makefile("pgplot")

# Append PGPLOT install task to Makefile
if $makefile_created
  puts "appending extra install tasks to Makefile"
  File.open("Makefile","a") do |w|
    w.print <<EOL

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
EOL
    if $found_lib.include? "X11"
      w.print <<EOL
	$(INSTALL_PROG) $(PGPLOT_BUILD)/pgxwin_server $(PGPLOT_DIR)

$(PGPLOT_BUILD)/pgxwin_server: $(PGPLOT_BUILD)/cpgplot.h
	(cd #{$subdir}; make build/pgxwin_server)
$(DLLIB): $(PGPLOT_BUILD)/pgxwin_server
EOL
    end
  end

  puts "creating #{$subdir}/drivers.conf"
  File.open("#{$subdir}/drivers.conf","w") do |w|
    w.puts "GIDRIV PPDRIV PSDRIV"
    w.puts "PNDRIV" if $found_lib.include? "png"
    w.puts "WDDRIV XWDRIV" if $found_lib.include? "X11"
  end
end
