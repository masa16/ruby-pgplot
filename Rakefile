require 'rubygems'
require 'rubygems/package_task'

load './pgplot.gemspec'

file 'ext/rb_pgplot.c' => ['ext/rb_pgplot.c.in', 'ext/cogen.rb'] do
  require './ext/cogen.rb'
  Dir.chdir('ext') do
    cogen_pgplot
  end
end

Gem::PackageTask.new(PGPLOT_GEMSPEC) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
