pkg=pgplot5.2.tar.gz
uri=ftp://ftp.astro.caltech.edu/pub/pgplot/$(pkg)
sd=pgplot
bd=build

all: $(bd)/makefile
	(cd $(bd); make all cpg)

$(pkg):
	ruby download.rb $(uri)

$(sd)/drivers.list: $(pkg)
	gunzip -c $(pkg) | tar xf -
	touch $(sd)/drivers.list
	ruby patch.rb

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
