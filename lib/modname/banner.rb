module Modname end


Modname::HelpBanner = <<-HELP
#{'Usage:'.cyan} modname [options] <command> [match] [transform]

#{'modname | rename files & extensions, fast'.cyan}
     -f #{'|'.cyan} force run; don't pre-check
     -r #{'|'.cyan} run modname recursively
     -h #{'|'.cyan} show more help, examples
HELP


Modname::VHelpBanner = <<-VHELP
#{Modname::HelpBanner}
#{'commands'.cyan}
  file names (f)
    [match] [trans] => modify a pattern in filenames
    [match] => delete a pattern from filenames

  extensions (e)
    [old] [new] => move file extensions, <old> to <new>
    [ext] => lowercase one extension type (EXT => ext)
    nil => move all extensions to lower case

#{'examples'.cyan}
  file names (f)
    modname f hello => deletes 'hello' from all filenames
    modname f hello byebye => replace 'hello' with byebye

  extensions (e)
    modname e txt md => move all txt files to markdown
    modname e mov mp4 => move all mov files to mp4

#{'Note:'.cyan} <required> [optional]
VHELP

