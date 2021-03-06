# modder rspec unit testing

require "spec_helper"

# no prompt for test
def Modder.confirm?
  true
end


describe Modder do
  # getting a class instance of modname
  def run
    Modname::Driver.new
  end

  # recursively getting all files from the current directory (testing)
  def files
    Find.find(Dir.pwd).select { |f| File.file? f }
      .map { |f| f.sub Dir.pwd << "/" , "" }
  end

  before "setup test directory" do
    $muted = true
    @dir = "testing"
    FileUtils.rm_rf @dir if Dir.exist? @dir
    Dir.mkdir(@dir) && Dir.chdir(@dir)
  end

  after "remove test files" do
    Dir.chdir(File.join Dir.pwd, "..")
    FileUtils.rm_rf @dir
  end


  context "Filenames" do
    before "create test files" do
      File.write "hello_clean.txt", "a"
      File.write "world_clean.txt", "b"
    end

    it "should delete by simple strings" do
      run.regex ["_clean"]
      nfiles = ["hello.txt", "world.txt"]
      expect(files).to eq nfiles
    end

    it "should delete beginnings by regex" do
      run.regex ["^.{4}"]
      nfiles = ["d_clean.txt", "o_clean.txt"]
      expect(files).to eq nfiles
    end

    it "should delete middles by regex" do
      run.regex ['_.*\.', "."]
      nfiles = ["hello.txt", "world.txt"]
      expect(files).to eq nfiles
    end

    it "should delete ends by regex" do
      run.regex ['\..*$']
      nfiles = ["hello_clean", "world_clean"]
      expect(files).to eq nfiles
    end

    it "should transform by string" do
      run.regex ["clean", "dirty"]
      nfiles = ["hello_dirty.txt", "world_dirty.txt"]
      expect(files).to eq nfiles

      run.regex ["dirty", "IMPURE"]
      nfiles = ["hello_IMPURE.txt", "world_IMPURE.txt"]
      expect(files).to eq nfiles
    end

    it "should transform by regex" do
      run.regex ['_.*\.', ".bak."]
      nfiles = ["hello.bak.txt", "world.bak.txt"]
      expect(files).to eq nfiles
    end
  end


  context "Extensions" do
    before "create test files" do
      File.write "a.TXT", "a"
      File.write "b.JPG", "b"
      File.write "c.TXT", "c"
    end

    it "should lowercase all file extensions by default" do
      run.exts # lowercases everything
      nfiles = ["a.txt", "b.jpg", "c.txt"]
      expect(files).to eq nfiles
    end

    it "should lowercase specific file extensions" do
      run.exts ["txt"] # lowercases text files
      nfiles = ["a.txt", "b.JPG", "c.txt"]
      expect(files).to eq nfiles
    end

    it "should move file extensions" do
      run.exts ["JPG", "txt"] # move to txt
      nfiles = ["a.TXT", "b.txt", "c.TXT"]
      expect(files).to eq nfiles
    end
  end


  context "Folders" do
    before "create test folders" do
      expect(false).to eq true
    end

    it "should work on folders when given -d flag" do
      expect(false).to eq true
    end

    it "should ignore folders without -d flag" do
      expect(false).to eq true
    end
  end


  context "Recursion" do
    class Modname::Driver
      attr_accessor :options
    end

    before "create more subfolders and files" do
      Dir.mkdir "a"
      File.write "a/hello_clean.txt", "a"
      File.write "a/world_clean.txt", "b"

      Dir.mkdir "b"
      File.write "b/a.TXT", "a"
      File.write "b/b.JPG", "b"
      File.write "b/c.TXT", "c"

      @tester = Modname::Driver.new
      @tester.options = { :recurse => true }
    end

    it "should handle extension execution" do
      @tester.exts ["JPG", "txt"] # move to txt
      nfiles = [ "a/hello_clean.txt", "a/world_clean.txt", "b/a.TXT", "b/b.txt", "b/c.TXT"]
      expect(files).to eq nfiles

      @tester.exts # move to lowercase
      nfiles = [ "a/hello_clean.txt", "a/world_clean.txt", "b/a.txt", "b/b.txt", "b/c.txt"]
      expect(files).to eq nfiles
    end

    it "should handle filename execution" do
      @tester.regex ["c", "g"] # testing strings
      nfiles = [ "a/hello_glean.txt", "a/world_glean.txt", "b/a.TXT", "b/b.JPG", "b/g.TXT"]
      expect(files).to eq nfiles

      @tester.regex ['_.*\.', "."]
      nfiles = [ "a/hello.txt", "a/world.txt", "b/a.TXT", "b/b.JPG", "b/g.TXT"]
      expect(files).to eq nfiles
    end
  end
end

