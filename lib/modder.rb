# modder, the modname helper
# generally: o-old, n-new


# any module including modder should implement:
# @transfer => hash of file transfers to occur


# extensions
module Modder
  # rename files based on regular expressions
  def regex(match, trans = "")
    Modder.files.each do |file|
      new = file.sub Regexp.new(match), trans

      next if (new == file || new == "") # no changes

      @transfer[file] = new
    end

    # warn if no actions to take after processing the files
    pexit "No matches for #{match}", 1 if @transfer.keys.nil?

    # print current changes
    Modder.status @transfer

    if Modder.confirm
      Modder.execute @transfer
    else
      puts "No modifications done."
    end
  end

  # change one file extension to another's type
  def extension(match, trans)
    # todo implement ext
  end
end


# module methods
class << Modder
  # double check transformations
  def confirm
    print "Are these changes ok? [yN] "
    (gets.chomp!).downcase[0] == "y"
  end

  # return a list of files we can work on
  def files
    Dir.entries(Dir.pwd).select do |file|
      File.file? file # handle files

      # todo handle filetypes

      # todo handle recursion
    end
  end

  # show the status of current files
  def status(transfer)
    # todo handle empty transfer hash
    puts "Planned file actions:".green
    transfer.each { |o, n| puts "\t#{o} -> #{n.green}" }
  end

  # rename all files
  def execute(transfer)
    transfer.each { |o, n| rename o, n }
  end

  # try to rename a given file
  def rename(o, n)
    begin
      exist = "#{'Error:'.red} target file #{n.green} already exists"
      (File.exist? n) ? raise(exist) : File.rename(o, n)

    rescue => e
      puts "#{'Error:'.red} could not move |#{o.red}| to |#{n.green}|"
      puts e.message
    end
  end
end

