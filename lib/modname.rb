# parse modname's command line args

require "colored"
require "modname/banner"
require "modname/modder"
require "modname/version"


module Modname
  class << self # defining Modname.run
    def run(*x) Driver.new.run x end
  end
end


class Modname::Driver
  VERSION = "0.1"
  include Modder
  def initialize
    @transfer = {}
  end

  # interface f-filename
  # e-extension

  # parse user arguments
  def run(args)
    opts = parse args
    cmd = opts[:cmd]
    args.shift
    case cmd
    when "ext"
      Modder.exts args
    when "file"
      Modder.regex args
    when "help"
      pexit Modname::VHELP_BANNER, 0
    when nil
      pexit Modname::HELP_BANNER, 0
    else
      puts "Unrecognized command:" + cmd
      pexit Modname::HELP_BANNER, 1
    end
  end

  # parse out arguments
  def parse(args)
    opts = {}
    opts[:args] = []
    loop do # each arg
      opt = args.shift
      case opt
      when "-h", "--help"
        opts[:cmd] = "help"
      when "-r"
        opts[:recurse] = true
      when "f", "file"
        opts[:cmd] = "file"
      when "e", "ext"
        opts[:cmd] = "ext"
      when nil # end of list
        break
      when /^-/ # unrecognized option
        puts "Unrecognized option:" + opt
        pexit Modname::HELP_BANNER, 1
      else # command argument
        opts[:args] << opt
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

