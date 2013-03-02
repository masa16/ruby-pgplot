pkg=pgplot5.2.tar.gz
sd=pgplot
bd=build
target=$(bd)/cpgplot.h\
 $(bd)/libcpgplot.a\
 $(bd)/libpgplot.a\
 $(bd)/grfont.dat\
 $(bd)/rgb.txt

all: $(bd)/makefile
	(cd $(bd); make all cpg)

$(pkg):
	ruby download.rb

$(sd)/drivers.list: $(pkg)
	gunzip -c $(pkg) | tar xf -
	touch $(sd)/drivers.list

$(bd)/drivers.list: drivers.conf $(sd)/drivers.list
	ruby drivers.rb $(sd) $(bd)

$(bd)/makefile: $(bd)/drivers.list
	ruby makefile.rb $(sd) $(bd)

$(bd)/libpgplot.a: $(bd)/makefile
	(cd $(bd); make libpgplot.a grfont.dat)

$(bd)/pgxwin_server: $(bd)/makefile
	(cd $(bd); make pgxwin_server)

$(bd)/libcpgplot.a: $(bd)/libpgplot.a
	(cd $(bd); make libcpgplot.a)
