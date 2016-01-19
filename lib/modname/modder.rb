# modder, the modname helper
# generally: o-old, n-new


# any module including modder should implement:
# @transfer => hash of file transfers to occur
# @options => hash with :recurse and :force


# extensions
module Modder

  # rename files based on regular expressions
  def regex(args = [])
    match, trans = Modder.parse args

    Modder.files(@options[:recurse]).each do |file|
      new = file.sub Regexp.new(match), trans

      next if (new == file || new == "") # no changes

      @transfer[file] = new
    end

    Modder.finish @transfer, @options[:force]
  end


  # change one file extension to another's type
  def exts(args = [])
    match, trans = Modder.parse args

    if match.empty? && trans.empty? # do all
      undercase_ext

    elsif trans.empty? # undercase one ext
      undercase_ext match

    else # move match extension to targeted
      Modder.files(@options[:recurse]).each do |file|
        new = file.sub /#{match}$/, trans

        next if new == file # no changes

        @transfer[file] = new
      end

      Modder.finish @transfer, @options[:force]
    end
  end

  # top level wrapper for exts
  def undercase_ext(ext = "")
    transfer = Modder.undercase_ext_get ext, @options[:recurse]
    Modder.undercase_ext_set ext, transfer, @options[:force]
  end
end


# module methods
class << Modder

  # return appropriate args, repairing if undefined
  def parse(args)
    match = args.shift
    trans = args.shift
    match = "" if match.nil?
    trans = "" if trans.nil?
    return match, trans
  end

  # double check transformations
  def confirm?
    print "Are these changes ok? [yN] "
    ($stdin.gets.chomp!).downcase[0] == "y"
  end

  # return a list of files to examine
  def files(recurse)
    if recurse
      Dir['**/*'].select { |f| File.file?(f) }
    else
      Dir.entries(Dir.pwd).select { |f| File.file? f }
    end
  end


  # show the status of current files
  def status(transfer)
    if transfer.empty?
      puts "No matches found.".yellow
    else
      puts "Planned file actions:".green
      transfer.each { |o, n| puts "\t#{o} -> #{n.green}" }
    end
  end

  # rename all files
  def execute(transfer)
    transfer.each { |o, n| Modder.rename o, n }
  end


  # finish up execution, highest level wrapper
  def finish(transfer, force)

    # print changes, return if none
    Modder.status transfer
    return if transfer.empty?

    if force || Modder.confirm?
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


  # get all extensions to change
  def undercase_ext_get(ext, recurse)
    transfer = Hash.new
    allexts = ext.empty?
    Modder.files(recurse).each do |file|
      ext = file.split(".").last if allexts

      new = file.sub /#{ext}$/i, ext.downcase
      next if new == file || ext == file # no changes or extension

      transfer[file] = new
    end

    transfer
  end

  # set all extensions to change
  # this involves moving it to a tmp file first, since most file systems are
  # not case sensitive and therefore wont distiniguish between HI and hi.
  # to get around this, we can set HI to HI.hash, then set HI.hash to hi
  def undercase_ext_set(ext, transfer, force)
    puts "Lowering extension: ".green + (ext.empty?? "*" : ext)

    Modder.status transfer
    return if transfer.empty?

    # confirm current changes
    if force || Modder.confirm?
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
      puts "Modifications complete."
    else
      puts "No modifications done."
    end
  end
end

