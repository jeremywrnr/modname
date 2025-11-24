# Adjust load path to include the lib directory
lib = File.expand_path("../../../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

# Start SimpleCov for test coverage (if available and requested)
if ENV['COVERAGE']
  begin
    require 'simplecov'
    require_relative 'coverage'
    
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

