# parse modname's command line args

module Modname
  VERSION = '0.1'
end


# module methods
class << Modname

  # parse the users arguments
  def run(args)
    cmd = args.shift
    pexit Modname::HELP_BANNER, 1 if cmd.nil?
    pexit Modname::VHELP_BANNER, 1 if cmd == '-h'
    #case cmd
    #when
  end

  # exit with a message and system signal
  def pexit(msg, sig)
    puts msg
    exit sig
  end
end

