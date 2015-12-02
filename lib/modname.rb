# parse modname's command line args


VERSION = "0.1"
require_relative 'modder'


class Modname
  # get user command
  def initialize(args)
    @mod = Modder.new
    parse args
  end

  # exit with a message and sys signal
  def pexit(msg, sig)
    puts msg
    exit sig
  end

  # parse the users arguments
  def parse(args)
    pexit HELP_BANNER, 1 if args.empty?
    pexit VHELP_BANNER, 1 if args.first == "-h"
    puts args
  end
end

Dir.entries(Dir.pwd)


# large constant strings


HELP_BANNER = <<-EOS
modname - a tool to rename files
    -m | modify filename on regex
    -h | show more modname help

Usage: modname [opts] <mods> [folder]

Transformations will be shown before they are executed, to double check
the transitition is what you were intending. Prevent this with -f.
EOS


VHELP_BANNER = <<-EOS
#{HELP_BANNER}
Options:
    -f        | force run; don't pre-check
    -r        | run modname recursively
    -t <type> | only change *.type files

Modifiers:
    -s | name files sequentially
    -d | name files from edit date-times
    -e | change file extensions
        <old> <new>
    -m | modify a filename, based on a regex.
        If -t option is not specified, delete <match> from name.
        <match-regex> [-t <transform-regex>]

Examples:
    modname -m hello -t byebye => replace hello with byebye
    modname -m hello => deletes hello from all filenames
    modname -e txt md => move all txt files to markdown
EOS

