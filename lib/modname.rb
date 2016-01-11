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

  # parse user arguments
  def run(args)
    opts = parse args
    cmd = opts[:cmd]
    args.shift

    case cmd
    when "ext"
      Modder.exts opts[:args]

    when "file"
      Modder.regex opts[:args]

    when "help"
      puts Modname::VHelpBanner

    when nil
      puts Modname::HelpBanner

    else
      puts "Unrecognized command: ".red + cmd
      puts Modname::HelpBanner
    end
  end

  # parse out arguments
  def parse(args)
    opts = {:args => []}

    loop do # each arg
      opt = args.shift
      case opt
      when "-h", "--help"
        opts[:cmd] = "help"
      when "-f"
        opts[:force] = true
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
        pexit Modname::HelpBanner, 1
      else # argument to command
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

