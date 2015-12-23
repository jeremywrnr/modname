# rspec unit testing for modder

require "spec_helper"

describe Modder do
  before "create test files" do
    Dir.mkdir("testing") unless Dir.exist? "testing"
    Dir.chdir("testing")
    File.write("1.txt", "1")
    File.write("2.txt", "2")
  end

  after "manipulating the workspace, clean cn folder" do
    Dir.chdir(File.join(Dir.pwd, ".."))
    FileUtils.rm_rf("testing")
  end

  it "should delete by regex" do
  end

  it "should transform by regex" do
  end

  it "should move file extensions" do
  end
end


