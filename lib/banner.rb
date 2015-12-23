module Modname
  HELP_BANNER = <<-EOS
Usage: modname [opts] <mods> [folder]

modname - a tool to rename files
    -e | change file extensions
    -m | modify filename pattern
    -h | show more modname help
  EOS

  VHELP_BANNER = <<-EOS
  #{Modname::HELP_BANNER}
    -f | force run; don't pre-check
    -r | run modname recursively

modifiers
    -t <type>
    => only look at changing *.type files

    -e <old> <new>
    => change file extensions

    -m <match-regex>
    => modify a filename, based on a regex.

        If -t option is not specified, delete <match> from name.
        [-t <transform-regex>]

examples
  file extensions
    modname -e txt md => move all txt files to markdown
    modname -e mov mp4 => move all mov files to mp4

  file names
    modname -m hello => deletes hello from all filenames
    modname -m hello -t byebye => replace hello with byebye

note: <required> [optional]
  EOS
end
