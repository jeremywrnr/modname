require 'rake'
require 'rspec/core/rake_task'

# gem name, version
g = 'modname'
v = '0.1'

task :build do
	system "gem build #{g}.gemspec"
	system "gem install ./#{g}-#{v}.gem"
end

task :clean do
	system "rm -fv *.gem"
end

task :push => :clean, :build do
	system "gem push #{g}-#{v}.gem"
end

task :dev do
  system "filewatcher '**/*.rb' 'clear && rake'"
end

task :default  => :spec

RSpec::Core::RakeTask.new(:spec) do |rake|
  rake.rspec_opts = '--format documentation'
  rake.verbose = true
end

