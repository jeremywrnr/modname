# parse modname's command line args


VERSION = "0.1"


class Modname
  # get user command
  def initialize(args)
    puts args
  end

  # exit with a message and sys signal
  def pexit(msg, sig)
    puts msg
    exit sig
  end
end


# large constant strings


HELP_BANNER = <<-EOS
modname - file renaming tool.
EOS
