# parse modname's command line args

module Modname
  VERSION = '0.1'
end

# module methods
class << Modname

  # parse user arguments
  def run(args)
    opts = parse args
    cmd = opts[:cmd]
    case cmd
    when 'help'
      pexit Modname::VHELP_BANNER, 0
    when nil
      pexit Modname::HELP_BANNER, 0
    else
      puts 'Unrecognized command:' + cmd
      pexit Modname::HELP_BANNER, 1
    end
  end

  # parse out arguments
  def parse(args)
    opts = {}
    loop do # each arg
      opt = args.shift
      case opt
      when '-h', '--help'
        opts[:cmd] = 'help'
      when '-r'
        opts[:recurse] = true
      when nil # end of list
        break
      else # unrecognized option
        puts 'Unrecognized option:' + opt
        pexit Modname::HELP_BANNER, 1
      end
    end

    opts
  end

  # exit w/ message and system signal
  def pexit(msg, sig)
    puts msg
    exit sig
  end
end

