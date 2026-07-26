# frozen_string_literal: true

# parse modname's command line args

require 'colored'
require_relative 'modname/banner'
require_relative 'modname/modder'
require_relative 'modname/version'

# Modname is a versatile file naming tool for renaming groups of files
module Modname
  # defining Modname.run
  class << self
    def run(args) = Driver.new.run(args)
  end

  # Driver class handles command-line argument parsing and execution
  class Driver
    include Modder

    attr_reader :options

    def initialize
      @options = { force: false, recurse: false, dirs: false }
      @transfer = {}
    end

    # parse user arguments
    def run(args)
      if args.empty?
        puts Modname::HELP_BANNER
      else
        opts = parse args
        cmd = opts[:cmd]

        case cmd
        when 'file'
          regex opts[:args]

        when 'ext'
          exts opts[:args]

        when 'help'
          puts Modname::V_HELP_BANNER

        when 'version'
          puts Modname::VERSION
        end
      end
    end

    # boolean options toggled by a single flag with no argument
    FLAGS = { '-f' => :force, '-r' => :recurse, '--dirs' => :dirs }.freeze

    # flags that select which command to run
    COMMANDS = {
      '-e' => 'ext', '--ext' => 'ext',
      '-h' => 'help', '--help' => 'help',
      '-v' => 'version', '--version' => 'version'
    }.freeze

    # parse out arguments
    def parse(args)
      opts = { cmd: 'file', args: [] }

      args.each do |opt|
        next @options[FLAGS[opt]] = true if FLAGS.key?(opt)
        next opts[:cmd] = COMMANDS[opt] if COMMANDS.key?(opt)

        opts[:args] << opt # command argument
      end

      opts
    end
  end
end
