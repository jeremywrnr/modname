# modname helper
# o-old, n-new


# module methods
module Modder
end


class << Modder
  # double check transformations
  def confirm
    print "Are these changes ok? [yN] "
    (gets.chomp!).downcase[0] == "y"
  end

  # return a list of files we can work on
  def files
    Dir.entries(Dir.pwd).select do |file|
      # todo handle filetypes
      # todo handle recursion
    end
  end

  # show the status of current files
  def status
    puts "Planned file actions:"
    @tranfer.each do |o, n|
      puts "\t#{o} -> #{n.grn}"
    end
  end

  # actually rename the files
  def execute
    @tranfer.each { |o, n| rename o, n }
  end

  # try to rename a given file
  def rename(o, n)
    begin
      exist = "Error: target file #{n} already exists".red
      File.exist? n ? raise(exist) : File.rename(o, n)
    rescue => e
      puts "Could not move #{o} to #{n}."
      puts e.message
    end
  end

  # rename files based on regular expressions
  def regex(match, trans = "")
    Modder.files.each do |file|
      new = file.replace(match, trans)

      next if new == file # no changes

      @transfer[old] = file
    end

    # warn if no actions to take after processing the files
    pexit "No matches for #{match}", 1 if @transfer.keys.nil?

    # print changes
    Modder.status

    if Modder.confirm
      Modder.execute
    else
      puts "No modifications done."
    end
  end

  # change one file extension to another's type
  def extension(match, trans)
    # todo implement ext
  end
end # Modder self

