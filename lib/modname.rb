# frozen_string_literal: true

# parse modname's command line args

require 'colored'
require 'modname/banner'
require 'modname/modder'
require 'modname/version'

module Modname
  # defining Modname.run
  class << self
    def run(x) = Driver.new.run(x)
  end
end

module Modname
  class Driver
    include Modder

    attr_reader :options

    def initialize
      @options = { force: false, recurse: false }
      @transfer = {}
    end

    # parse user arguments
    def run(args)
      if args.empty?
        puts Modname::HelpBanner
      else
        opts = parse args
        cmd = opts[:cmd]

        case cmd
        when 'file'
          regex opts[:args]

        when 'ext'
          exts opts[:args]

        when 'help'
          puts Modname::VHelpBanner

        when 'version'
          puts Modname::Version
        end
      end
    end

    # parse out arguments
    def parse(args)
      opts = { cmd: 'file', args: [] }

      args.each do |opt|
        case opt
        when '-f'
          @options[:force] = true
        when '-r'
          @options[:recurse] = true
        when '-e', '--ext'
          opts[:cmd] = 'ext'
        when '-h', '--help'
          opts[:cmd] = 'help'
        when '-v', '--version'
          opts[:cmd] = 'version'
        else # command argument
          opts[:args] << opt
        end
      end

      opts
    end
  end
end
