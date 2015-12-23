# rspec unit testing for modder

require "spec_helper"

unmute # allow output

describe Modder do
  before "create test files" do
    @modder = Modname.new
    Dir.mkdir "testing" unless Dir.exist? "testing"
    Dir.chdir "testing"
    File.write "hello_clean.txt", "1"
    File.write "world_clean.txt", "2"
  end

  after "remove test files" do
    Dir.chdir(File.join Dir.pwd, "..")
    FileUtils.rm_rf "testing"
  end

  it "should delete by regex" do
    puts `ls`
    @modder.regex "_clean"
    expect(File.exist? "hello.txt").to be true
    expect(File.exist? "world.txt").to be true
  end

  it "should transform by regex" do
  end

  it "should move file extensions" do
  end
end


