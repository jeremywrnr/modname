module Modder
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
    -e | change file extensions <old> <new>
    -m | modify a filename, based on a regex.
        If -t option is not specified, delete <match> from name.
        <match-regex> [-t <transform-regex>]

Examples:
    modname -m hello -t byebye => replace hello with byebye
    modname -m hello => deletes hello from all filenames
    modname -e txt md => move all txt files to markdown
  EOS
end
