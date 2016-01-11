# helper for rspec

require "FileUtils" # test cleanup
require_relative "../lib/modname"


# hacky mutable puts
$muted = true
def puts(*x)
  $muted? x : x.flat_map { |y| print y + "\n" }
end


# Allow new and old Rspec syntax
RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }
end


# Check program exit codes with rspec
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

