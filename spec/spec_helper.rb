# frozen_string_literal: true

# Adjust load path to include the lib directory
lib = File.expand_path('../../lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

# Start SimpleCov for test coverage (if available and requested)
if ENV['COVERAGE']
  begin
    require 'simplecov'

    # Use explicit ./ to avoid stdlib conflict
    require_relative 'spec_coverage'

    SimpleCov.start do
      add_filter '/spec/'
    end

    # SimpleCov's at_exit runs first, then ours
    SimpleCov.at_exit do
      SimpleCov.result.format!
      # Require 100% coverage - will exit 1 if below threshold
      display_coverage_summary(fail_under: 100.0)
    end
  rescue LoadError => e
    warn "SimpleCov not available: #{e.message}"
  end
end

# helper for rspec
require 'fileutils'
require 'modname'
require 'find'

# hacky mute-able puts
$muted = true
def puts(*x)
  $muted ? x.join : x.flat_map { |y| print "#{y}\n" }
end
