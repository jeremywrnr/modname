# rspec unit testing for modname

require "spec_helper"

describe Modname do
  def run(str) Modname.run str.split end
  def runblock(str = "") lambda { run str  } end

  it "should exit cleanly when no arguments are given" do
    runblock.should exit_with_code 0
  end

  it "should exit cleanly when asking for more help" do
    runblock("-h").should exit_with_code 0
    runblock("--help").should exit_with_code 0
  end

  it "should refuse unrecognized flags" do
    runblock("-goo?-gaah??").should exit_with_code 1
    runblock("-world -goo?").should exit_with_code 1
    runblock("--hello").should exit_with_code 1
  end
end

