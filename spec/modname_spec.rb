# rspec unit testing for modname

require "spec_helper"

describe Modname do
  def parse(str = '') Modname::Driver.new.parse str.split end
  def run(str = '') Modname::Driver.new.run str.split end

  before "mute program help output" do
    $muted = true
  end

  context "Parser" do
    it "should give correct help commands" do
      p = parse "--help" # generate hash
      expect(p[:cmd]).to eq "help"
    end

    it "should give correct command arguments" do
      p = parse "ext" # generate hash
      expect(p[:cmd]).to eq "ext"

      p = parse "e" # generate hash
      expect(p[:cmd]).to eq "ext"

      p = parse "file" # generate hash
      expect(p[:cmd]).to eq "file"

      p = parse "f" # generate hash
      expect(p[:cmd]).to eq "file"
    end

    it "should give correct command flags" do
      p = parse "ext" # generate hash
      expect(p[:recurse]).to be false
      expect(p[:force]).to be false

      p = parse "ext -r -f" # generate hash
      expect(p[:recurse]).to be true
      expect(p[:force]).to be true

      p = parse "ext -r hi hi" # generate hash
      expect(p[:recurse]).to be true
      expect(p[:force]).to be false

      p = parse "-f -r file joy" # generate hash
      expect(p[:recurse]).to be true
      expect(p[:force]).to be true
    end

    it "should stop on unrecognized flags" do
      p = parse "--goo" # generate hash
      expect(p[:err]).to eq ["--goo"]
    end
  end

  context "Runner" do
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
        expect(run cmd).to eq Modname::HelpBanner
      end
    end
  end
end

