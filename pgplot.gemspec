PGPLOT_GEMSPEC = Gem::Specification.new do |s|
  s.name = "pgplot"
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Masahiro Tanaka"]
  s.date = "2012-02-18"
  s.description = "PGPLOT wrapper for Ruby"
  s.email = "masa16.tanaka@gmail.com"
  s.extensions = ["ext/extconf.rb"]
  s.homepage = "http://pgplot.rubyforge.org/"
  s.require_paths = ["."]
  s.rubyforge_project = "pgplot"
  s.rubygems_version = "1.3.7"
  s.summary = "PGPLOT wrapper for Ruby. The PGPLOT library needs to be " \
              "installed in advance using GNU FORTRAN compiler"
  s.files = %w[
    README
    README.ja
    FuncUsage
    demo/pgdemo1.rb
    demo/pgdemo15.rb
    demo/pgdemo3.rb
    demo/pgdemo4.rb
    demo/pgdemo9.rb
    ext/cogen.rb
    ext/depend
    ext/extconf.rb
    ext/kwarg.c
    ext/rb_pgplot.c.in
    test/pgband.rb
    test/pgcurs.rb
    test/pggray.rb
    test/pglcur.rb
    test/pgline.rb
    test/pgncur.rb
    test/pgolin.rb
    test/pgtick.rb
  ]

  s.add_dependency('narray', '>= 0.5.0')

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end

  # Documentation TODO
  s.rdoc_options = %w[
    --title Ruby/PGPLOT
    --main README
    --exclude demo/
    --exclude ext/
    --exclude test/
    --exclude pgplot.*
  ]
  s.has_rdoc = true
  s.extra_rdoc_files = %w[README.ja FuncUsage]
end
