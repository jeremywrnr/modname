# parse modname's command line args


require "find"
require "colored"
require "modname/banner"
require "modname/modder"
require "modname/version"


module Modname
  class << self # defining Modname.run
    def run(x) Driver.new.run x end
  end
end


class Modname::Driver
  include Modder
  def initialize
    @transfer = {}
    @options = {}
  end

  # parse user arguments
  def run(args)
    opts = parse args
    cmd = opts[:cmd]

    case cmd
    when "ext"
      exts opts[:args]

    when "file"
      regex opts[:args]

    when "help"
      puts Modname::VHelpBanner

    when "version"
      puts Modname::Version

    when nil
      puts Modname::HelpBanner

    else
      puts "Unrecognized command: ".red + cmd
      puts Modname::HelpBanner
    end
  end

  # parse out arguments
  def parse(args)
    opts = {:args => [], :err => [], :force => false, :recurse => false}

    args.each do |opt|
      case opt
      when "-f"
        opts[:force] = true
      when "-r"
        opts[:recurse] = true
      when "-h", "--help"
        opts[:cmd] = "help"
      when "-v", "--version"
        opts[:cmd] = "version"
      when "f", "file"
        opts[:cmd] = "file"
      when "e", "ext"
        opts[:cmd] = "ext"
      when /^-/ # unrecognized option
        puts "Unrecognized option: ".red + opt
        puts Modname::HelpBanner
        opts[:err] << opt
      else # argument to command
        opts[:args] << opt
      end
    end

    opts
  end
end

