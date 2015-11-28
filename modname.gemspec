Gem::Specification.new do |g|
  g.name        = 'modname'
  g.version     = '0.1'
  g.date        = '2015-12-02'
  g.summary     = 'a versatile file naming tool.'
  g.description = 'easily rename groups of files with regex replacements.'
  g.homepage    = 'http://github.com/jeremywrnr/booker'
  g.author      = 'Jeremy Warner'
  g.email       = 'jeremywrnr@gmail.com'
  g.license     = 'MIT'
  g.executables = ['modname']
  g.files       = ['lib/modname.rb']
  g.add_development_dependency 'rspec', '~> 3.3', '>= 3.3.2'
end
