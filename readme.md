modname
=======


[![Gem Version](https://badge.fury.io/rb/modname.svg)](https://badge.fury.io/rb/modname)
[![MIT](https://img.shields.io/npm/l/alt.svg?style=flat)](http://jeremywrnr.com/mit-license)


## about

a versatile file naming tool.

easily rename groups of files with regex replacements.

also supports easily changing file extensions.


## setup

    [sudo] gem install modname

## usage

```
modname [options] <match> [transform]

modname | rename files, fast
     -e | change file extensions
     -f | force run; don't pre-check
     -r | run modname recursively
     -h | show more help, examples

commands
  file names
    atch] [trans] => modify a pattern in filenames
    atch] => delete a pattern from filenames

  extensions (-e)
    [old] [new] => move file extensions, <old> to <new>
    [ext] => lowercase one extension type (EXT => ext)
    nil => move all extensions to lower case

examples
  file names
    modname hello => deletes 'hello' from all filenames
    modname hello byebye => replace 'hello' with byebye

  extensions (-e)
    modname -e txt md => move all txt files to markdown
    modname -e mov mp4 => move all mov files to mp4

Note: <required> [optional]
```

### examples

    modname -e jpeg jpg # change all jpeg file exts to jpg
    modname -e # change all file extensions to lowercase
    modname '(.*)' 'jeremy \1' # use grouping to prepend string


## development / testing

To build from source, first install the project dependencies. This project
uses `bundler`, the standard ruby gem management system. If you don't have it,
try running `gem install bundler`. Once that is done:

    bundle install

Now, we should be able to build the gem locally. This will build the local
modname gem and link it in your path, so you can playing around with `modname`.

    just build

This uses `rspec` and `just` to run a suite of unit tests. To run the suite:

    just spec


## todos

- only try to rename filenames, not folders on recursive calls
- figure out whats up with the extension globbing
- apply optionally to directories as well

