module Modname end


Modname::HelpBanner = <<-HELP
#{'Usage:'.cyan} modname [options] <match> [transform]

#{'modname | rename files, fast'.cyan}
#{'--------┼----------------------------'.cyan}
     -e #{'|'.cyan} change file extensions
     -f #{'|'.cyan} force run; don't pre-check
     -r #{'|'.cyan} run modname recursively
     -h #{'|'.cyan} show more help, examples
HELP


Modname::VHelpBanner = <<-VHELP
#{Modname::HelpBanner}
#{'commands'.cyan}
  file names
    [match] [trans] => modify a pattern in filenames
    [match] => delete a pattern from filenames

  extensions (-e)
    [old] [new] => move file extensions, <old> to <new>
    [ext] => lowercase one extension type (EXT => ext)
    nil => move all extensions to lower case

#{'examples'.cyan}
  file names
    modname hello => deletes 'hello' from all filenames
    modname hello byebye => replace 'hello' with byebye

  extensions (-e)
    modname -e txt md => move all txt files to markdown
    modname -e mov mp4 => move all mov files to mp4

#{'Note:'.cyan} <required> [optional]
VHELP

