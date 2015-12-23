# rspec unit testing for modder


require "spec_helper"


# dont prompt while testing
def Modder.confirm() true end
unmute # allow output


describe Modder do
  def run() Modname::Driver.new end

  before "create test files" do
    @dir = "testing"
    FileUtils.rm_rf @dir if Dir.exist? @dir
    Dir.mkdir @dir
    Dir.chdir @dir
    File.write "hello_clean.txt", "a"
    File.write "world_clean.txt", "b"
  end

  after "remove test files" do
    Dir.chdir(File.join Dir.pwd, "..")
    FileUtils.rm_rf @dir
  end

  it "should delete by regex" do
    puts `ls`
    run.regex "_clean"
    puts `ls`
    expect(File.exist? "hello.txt").to be true
    expect(File.exist? "world.txt").to be true
  end

  it "should transform by regex" do
  end

  it "should move file extensions" do
  end
end

