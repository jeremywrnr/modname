# Adjust load path to include the lib directory
lib = File.expand_path("../../../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

# Start SimpleCov for test coverage (if available and requested)
if ENV['COVERAGE']
  begin
    require 'coverage'
    require 'simplecov'
    require_relative 'coverage'
    
    # Workaround for SimpleCov 0.22.0 bug with Ruby 3.3
    # SimpleCov looks for Coverage in its own namespace instead of global
    class << SimpleCov
      const_set(:Coverage, ::Coverage) unless const_defined?(:Coverage)
    end
    
    SimpleCov.start do
      add_filter '/spec/'
    end
  rescue LoadError, NameError => e
    warn "SimpleCov not available: #{e.message}"
  end
  
  # Display coverage summary at exit
  at_exit do
    display_coverage_summary rescue nil
  end
end

# helper for rspec
require "fileutils"
require "modname"
require "find"

# hacky mute-able puts
$muted = true
def puts(*x)
  $muted? x.join : x.flat_map { |y| print y + "\n" }
end

