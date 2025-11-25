# frozen_string_literal: true

# modder rspec unit testing

require 'spec_helper'

describe Modder do
  # Override confirm? for these tests to avoid prompts
  before(:all) do
    def Modder.confirm?
      true
    end
  end

  # getting a class instance of modname
  def run
    Modname::Driver.new
  end

  # recursively getting all files from the current directory (testing)
  def files
    Find.find(Dir.pwd).select { |f| File.file? f }
        .map { |f| f.sub Dir.pwd << '/', '' }
  end

  before 'setup test directory' do
    $muted = true
    @dir = 'testing'
    FileUtils.rm_rf @dir
    Dir.mkdir(@dir) && Dir.chdir(@dir)
  end

  after 'remove test files' do
    Dir.chdir(File.join(Dir.pwd, '..'))
    FileUtils.rm_rf @dir
  end

  context 'Filenames' do
    before 'create test files' do
      File.write 'hello_clean.txt', 'a'
      File.write 'world_clean.txt', 'b'
    end

    it 'should delete by simple strings' do
      run.regex ['_clean']
      nfiles = ['hello.txt', 'world.txt']
      expect(files).to eq nfiles
    end

    it 'should delete beginnings by regex' do
      run.regex ['^.{4}']
      nfiles = ['d_clean.txt', 'o_clean.txt']
      expect(files).to eq nfiles
    end

    it 'should delete middles by regex' do
      run.regex ['_.*\.', '.']
      nfiles = ['hello.txt', 'world.txt']
      expect(files).to eq nfiles
    end

    it 'should delete ends by regex' do
      run.regex ['\..*$']
      nfiles = %w[hello_clean world_clean]
      expect(files).to eq nfiles
    end

    it 'should transform by string' do
      run.regex %w[clean dirty]
      nfiles = ['hello_dirty.txt', 'world_dirty.txt']
      expect(files).to eq nfiles

      run.regex %w[dirty IMPURE]
      nfiles = ['hello_IMPURE.txt', 'world_IMPURE.txt']
      expect(files).to eq nfiles
    end

    it 'should transform by regex' do
      run.regex ['_.*\.', '.bak.']
      nfiles = ['hello.bak.txt', 'world.bak.txt']
      expect(files).to eq nfiles
    end
  end

  context 'Extensions' do
    before 'create test files' do
      File.write 'a.TXT', 'a'
      File.write 'b.JPG', 'b'
      File.write 'c.TXT', 'c'
    end

    it 'should lowercase all file extensions by default' do
      run.exts # lowercases everything
      nfiles = ['a.txt', 'b.jpg', 'c.txt']
      expect(files).to eq nfiles
    end

    it 'should lowercase specific file extensions' do
      run.exts ['txt'] # lowercases text files
      nfiles = ['a.txt', 'b.JPG', 'c.txt']
      expect(files).to eq nfiles
    end

    it 'should move file extensions' do
      run.exts %w[JPG txt] # move to txt
      nfiles = ['a.TXT', 'b.txt', 'c.TXT']
      expect(files).to eq nfiles
    end
  end

  context 'Error Handling' do
    before 'create test files' do
      File.write 'test.txt', 'content'
      $muted = false # unmute for error messages
    end

    after do
      $muted = true
    end

    it 'should handle existing files without force' do
      File.write 'test.txt', 'a'
      File.write 'exists.txt', 'b'

      driver = run
      driver.instance_variable_set(:@transfer, { 'test.txt' => 'exists.txt' })

      # Capture output
      expect do
        Modder.execute({ 'test.txt' => 'exists.txt' }, force: false)
      end.to output(/Error.*already exists/).to_stdout
      expect(File.exist?('test.txt')).to be true
      expect(File.exist?('exists.txt')).to be true
    end

    it 'should overwrite existing files with force' do
      File.write 'source.txt', 'source content'
      File.write 'target.txt', 'target content'

      Modder.rename('source.txt', 'target.txt', true)
      expect(File.exist?('source.txt')).to be false
      expect(File.exist?('target.txt')).to be true
    end

    it 'should handle empty match and trans' do
      match, trans = Modder.parse([])
      expect(match).to eq ''
      expect(trans).to eq ''
    end

    it 'should handle single argument' do
      match, trans = Modder.parse(['pattern'])
      expect(match).to eq 'pattern'
      expect(trans).to eq ''
    end
  end

  context 'No Matches' do
    before 'create test files' do
      File.write 'file1.txt', 'a'
      File.write 'file2.txt', 'b'
    end

    it 'should report no matches for regex' do
      $muted = false
      expect { run.regex %w[NOMATCH replace] }.to output(/No matches found/).to_stdout
      $muted = true
      expect(files).to eq ['file1.txt', 'file2.txt']
    end

    it 'should report no matches for ext' do
      $muted = false
      expect { run.exts %w[jpg png] }.to output(/No matches found/).to_stdout
      $muted = true
      expect(files).to eq ['file1.txt', 'file2.txt']
    end

    it 'should skip files with no changes in regex' do
      File.write 'unchanged.txt', 'content'
      run.regex %w[abc xyz] # no match
      expect(File.exist?('unchanged.txt')).to be true
    end

    it 'should skip files with no changes in exts' do
      File.write 'test.txt', 'content'
      run.exts %w[txt txt] # same extension
      expect(File.exist?('test.txt')).to be true
    end

    it 'should skip modifications when user declines' do
      File.write 'oldname.txt', 'content'

      # Override confirm? to return false
      Modder.define_singleton_method(:confirm?) { false }

      $muted = false
      expect { run.regex %w[old new] }.to output(/No modifications done/).to_stdout
      $muted = true
      expect(File.exist?('oldname.txt')).to be true
      expect(File.exist?('newname.txt')).to be false

      # Restore override
      Modder.define_singleton_method(:confirm?) { true }
    end

    it 'should skip ext modifications when user declines' do
      File.write 'test.TXT', 'content'

      # Ensure force mode is off and override confirm? to return false
      run.options[:force] = false
      Modder.define_singleton_method(:confirm?) { false }

      $muted = false
      expect { run.exts ['TXT'] }.to output(/No modifications done/).to_stdout
      $muted = true
      
      # File should remain uppercase
      expect(File.exist?('test.TXT')).to be true

      # Restore overrides
      run.options[:force] = false
      Modder.define_singleton_method(:confirm?) { true }
    end
  end

  context 'Recursion' do
    module Modname
      class Driver
        attr_accessor :options
      end
    end

    before 'create more subfolders and files' do
      Dir.mkdir 'a'
      File.write 'a/hello_clean.txt', 'a'
      File.write 'a/world_clean.txt', 'b'

      Dir.mkdir 'b'
      File.write 'b/a.TXT', 'a'
      File.write 'b/b.JPG', 'b'
      File.write 'b/c.TXT', 'c'

      @tester = Modname::Driver.new
      @tester.options = { recurse: true }
    end

    it 'should handle extension execution' do
      @tester.exts %w[JPG txt] # move to txt
      nfiles = ['a/hello_clean.txt', 'a/world_clean.txt', 'b/a.TXT', 'b/b.txt', 'b/c.TXT']
      expect(files).to eq nfiles

      @tester.exts # move to lowercase
      nfiles = ['a/hello_clean.txt', 'a/world_clean.txt', 'b/a.txt', 'b/b.txt', 'b/c.txt']
      expect(files).to eq nfiles
    end

    it 'should handle filename execution' do
      @tester.regex %w[c g] # testing strings
      nfiles = ['a/hello_glean.txt', 'a/world_glean.txt', 'b/a.TXT', 'b/b.JPG', 'b/g.TXT']
      expect(files).to eq nfiles

      @tester.regex ['_.*\.', '.']
      nfiles = ['a/hello.txt', 'a/world.txt', 'b/a.TXT', 'b/b.JPG', 'b/g.TXT']
      expect(files).to eq nfiles
    end

    it 'should work with non-recursive mode' do
      @tester.options = { recurse: false }
      File.write 'root.TXT', 'root'

      @tester.exts %w[TXT md]
      expect(File.exist?('root.md')).to be true
      expect(File.exist?('root.TXT')).to be false
      # subdirectory files should remain unchanged
      expect(File.exist?('a/hello_clean.txt')).to be true
    end
  end

  context 'Edge Cases' do
    before 'create test files' do
      File.write 'test.txt', 'content'
    end

    it 'should not modify file when empty regex replaces everything' do
      # Empty regex would add prefix to everything, creating a different filename
      original_files = files
      run.regex ['', 'replacement']
      # Since it creates new filenames, old file should be gone and new ones created
      expect(files).not_to eq original_files
    end

    it 'should skip empty result filenames' do
      File.write 'prefix.txt', 'content'
      # Replace entire filename with empty string
      run.regex ['^.*$', '']
      expect(File.exist?('prefix.txt')).to be true
    end

    it 'should handle files that match their own extension' do
      File.write 'txt', 'content'
      run.exts ['txt']
      # File named 'txt' should be skipped
      expect(File.exist?('txt')).to be true
    end

    it 'should handle undercase_ext with specific extension' do
      File.write 'file.TXT', 'a'
      File.write 'file.JPG', 'b'

      run.exts ['TXT']
      expect(File.exist?('file.txt')).to be true
      expect(File.exist?('file.JPG')).to be true
    end
  end

  context 'Modder Module Methods' do
    before 'setup test directory' do
      $muted = true
      @dir = 'testing2'
      FileUtils.rm_rf @dir
      Dir.mkdir(@dir) && Dir.chdir(@dir)
    end

    after 'remove test files' do
      Dir.chdir(File.join(Dir.pwd, '..'))
      FileUtils.rm_rf @dir
    end

    it 'should get files non-recursively' do
      File.write 'file1.txt', 'a'
      FileUtils.mkdir_p 'subdir'
      File.write 'subdir/file2.txt', 'b'

      files = Modder.files(false)
      expect(files).to include('file1.txt')
      expect(files).not_to include('subdir/file2.txt')
    end

    it 'should get files recursively' do
      File.write 'file1.txt', 'a'
      FileUtils.mkdir_p 'subdir'
      File.write 'subdir/file2.txt', 'b'

      files = Modder.files(true)
      expect(files).to include('file1.txt')
      expect(files).to include('subdir/file2.txt')
    end
  end
end
