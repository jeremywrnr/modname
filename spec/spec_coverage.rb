#!/usr/bin/env ruby
# frozen_string_literal: true

# Display test coverage summary from SimpleCov results

require 'json'
require 'colored'

def display_coverage_summary
  $muted = false # Ensure output is not suppressed
  coverage_file = 'coverage/.resultset.json'

  unless File.exist?(coverage_file)
    puts "Error: Coverage file not found at #{coverage_file}"
    puts 'Run tests first to generate coverage data.'
    exit 1
  end

  data = JSON.parse(File.read(coverage_file))['RSpec']['coverage']
  files = []

  data.each do |file, lines|
    next if file.include?('/spec/')

    total = 0
    covered = 0

    lines['lines'].each do |line_coverage|
      next unless line_coverage.is_a?(Integer)

      total += 1
      covered += 1 if line_coverage > 0
    end

    pct = total > 0 ? (covered.to_f / total * 100).round(2) : 0
    files << {
      name: file.sub("#{Dir.pwd}/", ''),
      pct: pct,
      covered: covered,
      total: total
    }
  end

  all_covered = files.sum { |f| f[:covered] }
  all_total = files.sum { |f| f[:total] }
  overall = all_total > 0 ? (all_covered.to_f / all_total * 100).round(2) : 0

  puts '=' * 80
  puts 'COVERAGE SUMMARY'
  puts '=' * 80
  puts "Overall: #{overall}% (#{all_covered}/#{all_total} lines)"
  puts ''

  files.sort_by { |f| f[:pct] }.each do |f|
    pct_str = "#{f[:pct].to_s.rjust(6)}%"
    colored_pct = if f[:pct] >= 90
                    pct_str.green
                  elsif f[:pct] >= 75
                    pct_str.yellow
                  else
                    pct_str.red
                  end
    puts "#{colored_pct}  #{f[:name]}"
  end

  puts '=' * 80
end

# Only run if called directly
display_coverage_summary if __FILE__ == $PROGRAM_NAME
