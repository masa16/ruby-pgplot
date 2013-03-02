pkg=pgplot5.2.tar.gz
sd=pgplot
bd=build
target=$(bd)/cpgplot.h\
 $(bd)/libcpgplot.a\
 $(bd)/libpgplot.a\
 $(bd)/grfont.dat\
 $(bd)/rgb.txt

all: $(bd)/libcpgplot.a

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
	(cd $(bd); make all)

$(bd)/libcpgplot.a: $(bd)/libpgplot.a
	(cd $(bd); make cpg)
