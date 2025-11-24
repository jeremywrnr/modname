# rspec unit testing for modname

require "spec_helper"

describe Modname do
  def parse(str = '') Modname::Driver.new.parse str.split end
  def run(str = '') Modname::Driver.new.run str.split end
  def get(str = '') Modname::Driver.new end

  before "mute program help output" do
    $muted = true
  end

  context "Runner" do
    it "should show standard help when given no args" do
      expect(get.run []).to eq Modname::HelpBanner
    end

    it "should advanced help when asked for more help" do
      %w{--help -h}.each { |h| expect(run h).to eq Modname::VHelpBanner }
    end

    it "should show version when asked" do
      %w{--version -v}.each do |v|
        expect(run v).to eq Modname::Version
      end
    end

    it "should call ext command with -e flag" do
      driver = get
      expect(driver).to receive(:exts).with(["txt", "md"])
      driver.run ["-e", "txt", "md"]
    end

    it "should call ext command with --ext flag" do
      driver = get
      expect(driver).to receive(:exts).with(["jpg"])
      driver.run ["--ext", "jpg"]
    end

    it "should call regex command with file arguments" do
      driver = get
      expect(driver).to receive(:regex).with(["old", "new"])
      driver.run ["old", "new"]
    end

    it "should call regex command with flags" do
      driver = get
      expect(driver).to receive(:regex).with(["pattern", "replacement"])
      driver.run ["-f", "pattern", "replacement"]
    end
  end

  context "Parser" do
    before "create a testing instance" do
      @mod = Modname::Driver.new
    end

    it "should give correct help commands" do
      p = parse "--help" # generate hash
      expect(p[:cmd]).to eq "help"

      p = parse "-h" # generate hash
      expect(p[:cmd]).to eq "help"
    end

    it "should give correct command arguments" do
      p = parse "file" # generate hash
      expect(p[:cmd]).to eq "file"

      p = parse "f" # generate hash
      expect(p[:cmd]).to eq "file"

      p = parse "--ext" # generate hash
      expect(p[:cmd]).to eq "ext"

      p = parse "-e" # generate hash
      expect(p[:cmd]).to eq "ext"

      p = parse "--goo" # generate hash
      expect(p[:cmd]).to eq "file"
    end

    it "should give correct command flags I" do
      @mod.parse %w{--ext} # generate hash
      expect(@mod.options[:recurse]).to be false
      expect(@mod.options[:force]).to be false
    end

    it "should give correct command flags II" do
      @mod.parse %w{--ext -r -f} # generate hash
      expect(@mod.options[:recurse]).to be true
      expect(@mod.options[:force]).to be true
    end

    it "should give correct command flags III" do
      @mod.parse %w{ext -r hi hi} # generate hash
      expect(@mod.options[:recurse]).to be true
      expect(@mod.options[:force]).to be false
    end

    it "should give correct command flags IV" do
      @mod.parse %w{-f -r file joy} # generate hash
      expect(@mod.options[:recurse]).to be true
      expect(@mod.options[:force]).to be true
    end
  end
end

