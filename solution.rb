require 'nokogiri'

if ARGV.length == 2
  in_file = ARGV[0]
  out_file = ARGV[1]
else
  help = 'Usage: solution.rb XML_INPUT_FILE OUT_DIRECTORY'
  puts help
  exit 0
end


