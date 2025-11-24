# justfile for modname

# Variables
gem_name := "modname"
version := `modname -v`

# Default recipe to run when just is called without arguments
default: spec

# Run tests with RSpec
spec:
    rspec --color --format documentation

# Build and install the gem
build:
    gem build {{gem_name}}.gemspec
    gem install ./{{gem_name}}-{{version}}.gem

# Clean up gem files
clean:
    @echo "cleaning gems..."
    rm -fv *.gem

# Clean, build, and push gem to RubyGems
push: clean build
    gem push {{gem_name}}-{{version}}.gem

# Development mode with file watching
dev:
    filewatcher '**/*.rb' 'clear && just spec'

# Show test coverage
coverage: spec
    @echo "Opening coverage report..."
    open coverage/index.html

# List all available recipes
help:
    @just --list
