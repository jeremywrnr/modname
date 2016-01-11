lib = File.expand_path("../../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)


# helper for rspec
require "modname"
require "FileUtils"


# hacky mutable puts
$muted = true
def puts(*x)
  $muted? x.join : x.flat_map { |y| print y + "\n" }
end

