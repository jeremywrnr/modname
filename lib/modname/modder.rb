# modder, the modname helper
# generally: o-old, n-new


# any module including modder should implement:
# @transfer => hash of file transfers to occur


# extensions
module Modder

  # rename files based on regular expressions
  def regex(args = [])
    trans = (args.length == 1 ? "" : args[1])
    match = args.first

    Modder.files.each do |file|
      new = file.sub Regexp.new(match), trans

      next if (new == file || new == "") # no changes

      @transfer[file] = new
    end

    # confirm + execute
    Modder.finish @transfer
  end


  # change one file extension to another's type
  def exts(args = [])
    trans = args.length <= 1 ? "" : args[1]
    match = args.first.nil?? "" : args.first

    if match.empty? && trans.empty? # do all
      Modder.undercase_ext

    elsif trans.empty? # undercase one ext
      Modder.undercase_ext match

    else # move match extension to targeted
      Modder.files.each do |file|
        new = file.sub /#{match}$/, trans

        next if new == file # no changes

        @transfer[file] = new
      end

      # confirm + execute
      Modder.finish @transfer
    end
  end
end


# module methods
class << Modder

  # double check transformations
  def confirm?
    print "Are these changes ok? [yN] "
    ($stdin.gets.chomp!).downcase[0] == "y"
  end

  # return a list of files to examine
  def files
    Dir.entries(Dir.pwd).select do |file|
      File.file? file # handle files
      # todo handle recursion
    end
  end


  # show the status of current files
  def status(transfer)
    if transfer.empty?
      "No matches found.".yellow
    else
      puts "Planned file actions:".green
      transfer.each { |o, n| puts "\t#{o} -> #{n.green}" }
    end
  end

  # rename all files
  def execute(transfer)
    transfer.each { |o, n| Modder.rename o, n }
  end


  # finish up execution
  # highest level wrapper
  def finish(transfer)
    # warn if no actions to take after processing the files

    # print current changes
    Modder.status transfer

    if Modder.confirm?
      Modder.execute transfer
      puts "Modifications complete."
    else
      puts "No modifications done."
    end
  end

  # try to rename a given file
  def rename(o, n)
    begin
      exist = "#{'Error:'.red} target file |#{n.green}| already exists"
      (File.exist? n) ? raise(exist) : File.rename(o, n)

    rescue => e
      puts "#{'Error:'.red} could not move |#{o.red}| to |#{n.green}|"
      puts e.message
    end
  end


  # top level wrapper for exts
  def undercase_ext(ext = "")
    transfer = undercase_ext_get ext
    undercase_ext_set ext, transfer
  end

  # get all extensions to change
  def undercase_ext_get(ext)
    transfer = Hash.new
    allexts = ext.empty?
    Modder.files.each do |file|
      ext = file.split(".").last if allexts

      new = file.sub /#{ext}$/i, ext.downcase
      next if new == file # no changes

      transfer[file] = new
    end

    transfer
  end

  # set all extensions to change
  # this involves moving it to a tmp file first, since most file systems are
  # not case sensitive and therefore wont distiniguish between HI and hi.
  # to get around this, we can set HI to HI.hash, then set HI.hash to hi
  def undercase_ext_set(ext, transfer)
    puts "Lowering extension: ".green + (ext.empty?? "*" : ext)

    # confirm current changes
    Modder.status transfer
    if Modder.confirm?
      final = {}
      temp = {}

      # create hash temp map
      transfer.each do |k, v|
        tempfile = (v.hash * v.object_id).abs.to_s
        final[tempfile] = v
        temp[k] = tempfile
      end

      Modder.execute temp
      Modder.execute final
    else
      puts "No modifications done."
    end
  end
end

