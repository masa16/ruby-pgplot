sftp rubyforge <<EOF
cd /var/www/gforge-projects/pgplot
put index.html
put pgcont.html
put pghist.html
put pgimag.html
put pgline.html
put rbpg-ind.html
put rbpgplot.html
put install.ja.html
put method.ja.html
put tutorial-01.ja.html
put ../README
put ../README.ja
put *.png
quit
EOF
