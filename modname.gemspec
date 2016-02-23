lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "modname/version"

Gem::Specification.new do |g|
  g.author      = "Jeremy Warner"
  g.email       = "jeremywrnr@gmail.com"

  g.name        = "modname"
  g.version     = Modname::Version
  g.platform    = Gem::Platform::RUBY
  g.date        = Time.now.strftime("%Y-%m-%d")
  g.summary     = 'a versatile file naming tool.'
  g.description = 'easily rename groups of files with regex replacements.'
  g.homepage    = 'http://github.com/jeremywrnr/modname'
  g.license     = "MIT"

  g.add_dependency "colored", ">= 1.2"
  g.add_development_dependency "rake"
  g.add_development_dependency "ronn"
  g.add_development_dependency "rspec"
  g.add_development_dependency "rspec-mocks"

  g.files        = Dir.glob("{bin,lib}/**/*") + %w(readme.md)
  g.executables = ['modname']
  g.require_path = 'lib'
end
