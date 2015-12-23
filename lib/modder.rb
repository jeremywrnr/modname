# modname helper
# o-old, n-new


# any module include modder should expose @transfer
# hash of file transfers waiting to occur.


# extensions
module Modder
  # rename files based on regular expressions
  def regex(match, trans = "")
    Modder.files.each do |file|
      new = file.gsub match, trans

      next if new == file # no changes

      @transfer[file] = new
    end

    # warn if no actions to take after processing the files
    pexit "No matches for #{match}", 1 if @transfer.keys.nil?

    # print changes
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
    puts "Planned file actions:".grn
    transfer.each do |o, n|
      puts "\t#{o} -> #{n.grn}"
    end
  end

  # rename all files
  def execute(transfer)
    transfer.each { |o, n| rename o, n }
  end

  # try to rename a given file
  def rename(o, n)
    begin
      exist = "#{'Error:'.red} target file #{n.grn} already exists"
      (File.exist? n) ? raise(exist) : File.rename(o, n)

    rescue => e
      puts "#{'Error:'.red} could not move #{o.red} to #{n.grn}"
      puts e.message
    end
  end
end

