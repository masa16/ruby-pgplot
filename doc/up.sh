sftp rubyforge <<EOF
cd /var/www/gforge-projects/pgplot
put index.html
put pgcont.html
put pghist.html
put pgimag.html
put pgline.html
put rbpg-ind.html
put rbpgplot.html
put install.html.ja
put method.html.ja
put tutorial-01.html.ja
put ../README
put ../README.ja
put *.png
quit
EOF
