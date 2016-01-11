# rspec unit testing for modname

require "spec_helper"

describe Modname do
  def run(str = '') Modname::Driver.new.run str.split end
  def runblock(str = "") lambda { run str  } end

  before "mute program help output" do
    $muted = true
  end

  it "should show standard help when given no args" do
    expect(run).to eq Modname::HelpBanner
  end

  it "should advanced help when asked for more help" do
    ["--help", "-h"].each do |help|
      expect(run help).to eq Modname::VHelpBanner
    end
  end

  it "should refuse unrecognized flags" do
    ["-goo?-gaah??", "-world -goo?", "--hello"].each do |cmd|
      expect(run cmd).to
      eq "Unrecognized command: ".red + cmd + Modname::HelpBanner
    end
  end
end

