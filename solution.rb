require_relative './lib/exif_processor.rb'

if __FILE__ == $0
  if ARGV.length == 2
    in_file = ARGV[0]
    out_dir = ARGV[1]
    ExifProcessor.new(in_file, out_dir).process
  else
    help = <<-MSG
  Usage: solution.rb XML_INPUT_FILE OUT_DIRECTORY
  example: ruby solution.rb ./resources/works.xml ./_html
  MSG
    puts help
    exit 0
  end
end
