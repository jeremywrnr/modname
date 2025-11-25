# justfile for modname

# Variables
gem_name := "modname"
version := `modname -v 2>/dev/null || echo "0.0.0"`

# Run tests with RSpec
spec:
    rspec --color --format documentation

# Format/lint code with RuboCop
lint:
    rubocop -A lib/ bin/

# Build and install the gem
build:
    gem build {{gem_name}}.gemspec
    gem install ./{{gem_name}}-{{version}}.gem

# Clean up gem files
clean:
    @echo "cleaning gems..."
    rm -fv *.gem

# Clean, build, and push gem to RubyGems
push: clean build ci
    gem push {{gem_name}}-{{version}}.gem

# Development mode with file watching
dev:
    filewatcher '**/*.rb' 'clear && just spec'

# Run tests and show coverage in terminal
cov:
    @COVERAGE=1 rspec --color --format progress

# Show HTML test coverage
cov-html: cov
    open coverage/index.html

# Run CI checks
ci: spec cov lint

# List all available recipes
help:
    @just --list
