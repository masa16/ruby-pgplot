.SUFFIXES: .rd .html .ja.rd .html.ja .rb $(SUFFIXES)

rd2=ruby myrd2html.rb

.rd.html:
	$(rd2) --lang=en --kw="Ruby,PGPLOT,NArray" $(opt) $< > $@

.ja.rd.html.ja:
	$(rd2) --lang=ja --kw="Ruby,PGPLOT,NArray" $(opt) $< > $@

all=index.html \
 pgline.html \
 pgcont.html \
 pgimag.html \
 pghist.html \
 rbpgplot.html \
 rbpg-ind.html \
 install.html.ja \
 tutorial-01.html.ja \
 method.html.ja

all: $(all)

# Examples
index.html: opt= --title="Ruby/PGPLOT"
pgline.html: opt= --title="pgline : Line plot"
pgcont.html: opt= --title="pgcont : Histogram plot"
pgimag.html: opt= --title="pgimag : Contour plot"
pghist.html: opt= --title="pghist : Image map"
rbpgplot.html: opt= --title="Ruby/PGPLOT: Method Index and Description"
rbpg-ind.html: opt= --title="Ruby/PGPLOT: Categorized Method Index"
install.html.ja: opt= --title="Ruby/PGPLOT: Installation (ja)"
tutorial-01.html.ja: opt= --title="Ruby/PGPLOT: Tutorial 01 (ja)"
method.html.ja: opt= --title="Ruby/PGPLOT: Method Reference (ja)"

pgline.html: pgline.rd trailer.html
pgcont.html: pgcont.rd trailer.html
pgimag.html: pgimag.rd trailer.html
pghist.html: pgimag.rd trailer.html
install.html.ja: trailer.html
tutorial-01.html.ja: tutorial-01.ja.rd trailer.html

# Method description
rbpgplot.html: mkdoc.rb
	#ruby -Kn mkdoc.rb $(HOME)/2012/src/pgplot/src rbpgplot.html
	ruby mkdoc.rb rbpgplot.html

# Method index categolized
rbpg-ind.rd: rbpg-ind.txt mkind.rb trailer.html
	ruby mkind.rb rbpg-ind.txt rbpg-ind.rd

rbpg-ind.html: rbpg-ind.rd

up:
	sh up.sh

clean:
	rm -f *~ rbpg-ind.rd $(all)
