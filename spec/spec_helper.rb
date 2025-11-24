# Adjust load path to include the lib directory
lib = File.expand_path("../../../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

# Start SimpleCov for test coverage (if available and requested)
if ENV['COVERAGE']
  begin
    require 'simplecov'

    # Use explicit ./ to avoid stdlib conflict
    require_relative './spec_coverage'
    
    SimpleCov.start do
      add_filter '/spec/'
    end
    
    # SimpleCov's at_exit runs first, then ours
    SimpleCov.at_exit do
      SimpleCov.result.format!
      display_coverage_summary
    end
  rescue LoadError => e
    warn "SimpleCov not available: #{e.message}"
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

