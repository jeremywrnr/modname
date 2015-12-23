# modname helper

module Modder
  @@tranfer = {}
end

# module methods
class << Modder

  # double check transformations
  def confirm
    print 'Are these changes ok? [yN] '
    (gets.chomp!).downcase[0] == 'y'
  end

  # show the status of current files
  def status
    puts 'Planned file actions:'
    @@tranfer.each do |o, n|
      puts "\t#{o} -> #{n}"
    end
  end

  # actually rename the files
  def transfer
    @@tranfer.each do |o, n|
      # todo move the file
    end
  end

  # rename files based on regular expressions
  def regex(match, trans)
    Dir.entries(Dir.pwd).each do |file|
      new = file.replace(match, trans)
      next if new == file # no changes
      @@transfer[old] = file
    end

    # warn if no actions to take
    pexit 'No matches for #{match}', 1 if transfer.keys.nil?

    # print changes
    Modder.status

    if Modder.confirm
      Modder.transfer
    else
      puts 'No modifications done.'
    end
  end

  # change one file extension to another's type
  def extension(match, trans)
    # todo
  end

  # rename files sequentially (a1, a2, a3, ...)
  def sequential(match)
    # todo
  end
end # Modder self

