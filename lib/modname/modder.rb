# frozen_string_literal: true

# modder, the modname helper
# generally: o-old, n-new

# any module including modder should implement:
# @transfer => hash of file transfers to occur
# @options => hash with :recurse, :force, and :dirs

# extensions
module Modder
  # rename files based on regular expressions
  def regex(args = [])
    match, trans = Modder.parse args

    Modder.files(@options[:recurse], dirs: @options[:dirs]).each do |file|
      new = Modder.rename_base(file) do |base|
        result = base.sub Regexp.new(match), trans
        result.empty? ? base : result # no changes
      end

      next if new.nil?

      @transfer[file] = new
    end

    Modder.finish @transfer, force: @options[:force]
  end

  # change one file extension to another's type
  def exts(args = [])
    match, trans = Modder.parse args

    if match.empty? && trans.empty? # do all
      undercase_ext

    elsif trans.empty? # undercase one ext
      undercase_ext match

    else # move match extension to targeted
      Modder.files(@options[:recurse], dirs: @options[:dirs]).each do |file|
        new = Modder.rename_base(file) { |base| base.sub(/#{match}$/, trans) }

        next if new.nil?

        @transfer[file] = new
      end

      Modder.finish @transfer, force: @options[:force]
    end
  end

  # top level wrapper for exts
  def undercase_ext(ext = '')
    transfer = Modder.undercase_ext_get ext, @options[:recurse], dirs: @options[:dirs]
    Modder.undercase_ext_set ext, transfer, @options[:force]
  end
end

# module methods
class << Modder
  # return appropriate args, repairing if undefined
  def parse(args)
    match = args.shift
    trans = args.shift
    match = '' if match.nil?
    trans = '' if trans.nil?
    [match, trans]
  end

  # double check transformations
  def confirm?
    print 'Are these changes ok? [yN] '
    $stdin.gets.chomp.downcase[0] == 'y'
  end

  # return a list of files (and, optionally, directories) to examine.
  # files always come first; directories are sorted deepest-first so a
  # parent is only renamed after everything nested inside it.
  # dotfiles/dotdirs (.git, etc.) are always excluded, matching Dir['**/*']'s
  # default behavior in the recursive case
  def files(recurse, dirs: false)
    paths = recurse ? Dir['**/*'] : Dir.entries(Dir.pwd).reject { |f| f.start_with?('.') }
    found, folders = Modder.classify(paths)

    return found unless dirs

    found + folders.sort_by { |f| -f.count('/') }
  end

  # split paths into [files, directories]; a single stat covers both checks
  # per path, skipping entries that vanished mid-scan or are broken symlinks
  def classify(paths)
    paths.each_with_object([[], []]) do |f, (fs, ds)|
      stat = Modder.safe_stat(f)
      next unless stat

      fs << f if stat.file?
      ds << f if stat.directory?
    end
  end

  # stat a path, returning nil (instead of raising) for entries that
  # disappeared mid-scan or are broken symlinks
  def safe_stat(file)
    File.stat(file)
  rescue Errno::ENOENT
    nil
  end

  # apply a transformation to a file's basename only, preserving its directory.
  # the block receives the basename and returns a new basename; returning it
  # unchanged means no rename should happen, in which case nil is returned
  def rename_base(file)
    dir, base = File.split(file)
    new_base = yield base

    return nil if new_base == base

    dir == '.' ? new_base : File.join(dir, new_base)
  end

  # show the status of current files
  def status(transfer)
    if transfer.empty?
      puts 'No matches found.'.yellow
    else
      puts 'Planned file actions:'.green
      transfer.each { |o, n| puts "\t#{o} -> #{n.green}" }
    end
  end

  # rename all files. must run in insertion order: when directories are
  # included, Modder.files places them deepest-first so a parent is never
  # renamed before what's nested inside it
  def execute(transfer, force: false)
    transfer.each { |o, n| Modder.rename o, n, force }
  end

  # finish up execution, highest level wrapper
  def finish(transfer, force: false)
    # print changes, return if none
    Modder.status transfer
    return if transfer.empty?

    if force || Modder.confirm?
      Modder.execute transfer, force: force
      puts 'Modifications complete.'
    else
      puts 'No modifications done.'
    end
  end

  # try to rename a given file
  def rename(old, new, force)
    exist = "#{'Error:'.red} target file |#{new.green}| already exists"

    # only overwrite when forced
    raise(exist) if (!force) && File.exist?(new)

    File.rename(old, new)
  rescue StandardError => e
    puts "#{'Error:'.red} could not move |#{old.red}| to |#{new.green}|"
    puts e.message
  end

  # get all extensions to change
  def undercase_ext_get(ext, recurse, dirs: false)
    transfer = {}
    allexts = ext.empty?
    Modder.files(recurse, dirs: dirs).each do |file|
      new = Modder.rename_base(file) do |base|
        cur_ext = allexts ? base.split('.').last : ext
        next base if cur_ext == base # no extension to change

        base.sub(/#{cur_ext}$/i, cur_ext.downcase)
      end

      next if new.nil?

      transfer[file] = new
    end

    Modder.resolve_dir_renames(transfer)
  end

  # rewrite each target path so it reflects any ancestor directory renames
  # also present in this transfer. undercase_ext_set flattens every entry to
  # a bare temp name before restoring it, which loses the "renaming a
  # directory carries its contents along" guarantee that Modder.execute
  # otherwise gets for free from File.rename — so a nested file's precomputed
  # target must have its renamed ancestor directory's NEW name spliced in
  def resolve_dir_renames(transfer)
    dir_renames = transfer.select { |k, _| File.directory?(k) }
    return transfer if dir_renames.empty?

    transfer.transform_values do |target|
      dir_renames.reduce(target) do |path, (old_dir, new_dir)|
        path.start_with?("#{old_dir}/") ? path.sub("#{old_dir}/", "#{new_dir}/") : path
      end
    end
  end

  # set all extensions to change
  # this involves moving it to a tmp file first, since most file systems are
  # not case sensitive and therefore wont distiniguish between HI and hi.
  # to get around this, we can set HI to HI.hash, then set HI.hash to hi
  def undercase_ext_set(ext, transfer, force)
    puts 'Lowering extension: '.green + (ext.empty? ? '*' : ext)

    Modder.status transfer
    return if transfer.empty?

    # confirm current changes
    if force || Modder.confirm?
      final = {}
      temp = {}

      # create hash temp map; iterating `transfer` preserves its deepest-first
      # directory ordering, which `temp` needs to safely rename originals away
      transfer.each do |k, v|
        tempfile = (v.hash * v.object_id).abs.to_s
        final[tempfile] = v
        temp[k] = tempfile
      end

      Modder.execute temp
      # `transfer`'s order is files-then-dirs-deepest-first (see Modder.files);
      # reversing it gives dirs-shallowest-first-then-files, which is exactly
      # what's needed to restore ancestors before anything nested inside them
      Modder.execute(final.to_a.reverse)
      puts 'Modifications complete.'
    else
      puts 'No modifications done.'
    end
  end
end
