# modname helper


class Modder

	@@tranfer = {}

	def initialize
	end

	# show the status of current files
	def status
	end

	# double check transformations
	def confirm
	end

	# rename files based on regular expressions
	def rename_regex(match, trans)
		puts "Planned file actions:\n\n";
		Dir.entries(Dir.pwd).each do |file|
			new = file.replace(match, trans)
			next if new == file
			puts "\t#{old} -> #{file}"
			transfer[old] = file
		end

		# warn if no actions to take
		if transfer.keys.nil?
			pexit "No matches for #{match}", 1
		else
			confirm
		end

		# change one file extension to another's type
		def rename_ext
		end

		# rename files sequentially (a1, a2, a3, ...)
		def rename_seq
		end
	end

