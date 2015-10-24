require 'nokogiri'
require 'erb'
require 'pry'

# A batch processor that takes an input file and produces one HTML file for each
# camera make, one for each camera model and also an index.
class ExifProcessor
  def initialize(xml_infile, out_dir)
    @out_dir = out_dir
    @xml = File.open(xml_infile) do |f|
      Nokogiri::XML(f)
    end
  end

  def process
    cameras = parse(@xml)
    write_index(cameras)
  end

  private

  # Writes an index file with thumbnails for first 10 works and a navigation
  # for browsing to camera make pages
  def write_index(cameras)
    @title = "Camera Index"
    # order wasn't specified so just use the order they came in
    @thumbnail_urls = cameras.slice(0, 10).map do |camera|
      camera[:image_url]
    end

    @makes = cameras.map {|c| c[:make]}.uniq.map do |make|
      {
        make: make,
        filename: sanitize_filename(make + '.html')
      }
    end

    out_path = @out_dir + '/index.html'
    File.open(out_path, 'w') do |f|
      template = File.open("templates/index.html.erb").read
      erb = ERB.new(template, 0, '>')
      f.write(erb.result(binding))
    end
  end

  # Extract salient data into an array of 'cameras'
  def parse(xml)
    # assume only one 'works' node
    xml.xpath('//work').map do |work|
      make_node = work.at_xpath('exif/make')
      model_node = work.at_xpath('exif/model')
      image_url_node = work.at_xpath("urls/url[@type='small']")

      # Do nothing unless the Work has usable data
      next unless make_node && model_node && image_url_node

      {
        make: make_node.text,
        model: model_node.text,
        image_url: image_url_node.text
      }
    end.compact
  end

  def sanitize_filename(filename)
    filename.strip.tap do |name|
      # NOTE: File.basename doesn't work right with Windows paths on Unix
      # get only the filename, not the whole path
      name.gsub!(/^.*(\\|\/)/, '')

      # Strip out the non-ascii character
      name.gsub!(/[^0-9A-Za-z.\-]/, '_')
    end
  end
end

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
