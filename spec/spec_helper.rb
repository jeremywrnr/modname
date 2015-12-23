# helper for rspec


require "FileUtils"
require_relative "../lib/banner"
require_relative "../lib/modder"
require_relative "../lib/modname"


# Allow new and old Rspec syntax
RSpec.configure do |config|
  config.expect_with(:rspec) do |c|
    c.syntax = [:should, :expect]
  end
end

# Redirect stderr and stdout for testing
def mute
  RSpec.configure do |config|
    unless $muted
      $original_stdout = $stdout
      $original_stderr = $stderr
      $stdout = File.open(File::NULL, "w")
      $stderr = File.open(File::NULL, "w")
      $muted = true
    end
  end
end

# Reallow stderr and stdout for testing
def unmute
  RSpec.configure do |config|
    if $muted
      $stdout = $original_stdout
      $stderr = $original_stderr
    end
  end
end


# Check exit codes with rspec
RSpec::Matchers.define :exit_with_code do |code|
  def supports_block_expectations?() true end
  actual = nil
  match do |block|
    begin
      block.call
    rescue SystemExit => e
      actual = e.status
    end
    actual && actual == code
  end
  failure_message do |block|
    "expected block to call exit(#{code}) but exit" +
      (actual.nil? ? " not called" : "(#{actual}) was called")
  end
  failure_message_when_negated do |block|
    "expected block not to call exit(#{exp_code})"
  end
  description do
    "expect block to call exit(#{exp_code})"
  end
end

