require 'erb'
require 'nokogiri'
# A batch processor that takes an input file and produces one HTML file for each
# camera make, one for each camera model and also an index.
class ExifProcessor
  def initialize(xml_infile, out_dir)
    @out_dir = out_dir
    @xml = File.open(xml_infile) do |f|
      Nokogiri::XML(f)
    end
  end

  # Parse xml file, then write index page, make pages and model pages
  # Example output structure looks like this:
  # out_dir
  # ├── Canon
  # │   ├── Canon_EOS_20D.html
  # │   ├── Canon_EOS_400D_DIGITAL.html
  # │   └── index.html
  # ├── FUJIFILM
  # │   ├── FinePix_S6500fd.html
  # │   └── index.html
  # ├── FUJI_PHOTO_FILM_CO.__LTD.
  # │   ├── SLP1000SE.html
  # │   └── index.html
  # ├── LEICA
  # │   ├── D-LUX_3.html
  # │   └── index.html
  # ├── NIKON_CORPORATION
  # │   ├── NIKON_D80.html
  # │   └── index.html
  # ├── Panasonic
  # │   ├── DMC-FZ30.html
  # │   └── index.html
  # └── index.html
  def process
    cameras = parse(@xml)

    write_index(cameras)

    cameras.group_by {|c| c[:make]}.each do |make, cameras|
      write_make(make, cameras)
      cameras.group_by {|c| c[:model]}.each do |model, cameras|
        write_model(make, model, cameras)
      end
    end
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

    @makes = extract_makes(cameras)

    index_page = @out_dir + '/index.html'
    File.open(index_page, 'w') do |f|
      template = File.open("templates/index.html.erb").read
      erb = ERB.new(template, 0, '>')
      f.write(erb.result(binding))
    end
  end

  # Writes an html file for a camera make with the first 10 works of that make
  # and navigation to allow the user to browse to the index page and to each
  # make
  def write_make(make, cameras)
    @title = make

    @thumbnail_urls = cameras.slice(0, 10).map do |camera|
      camera[:image_url]
    end

    @models = extract_models(cameras)

    # Create the make subdirectory if it doesn't exist already
    make_dir = "#{@out_dir}/#{sanitize_filename(make)}"
    Dir.mkdir(make_dir) unless File.exist?(make_dir)

    make_page =  make_dir + '/index.html'
    File.open(make_page, 'w') do |f|
      template = File.open("templates/make.html.erb").read
      erb = ERB.new(template, 0, '>')
      f.write(erb.result(binding))
    end
  end

  # Writes an html file for a camera model with the first 10 works of that model
  # and navigation to allow the user to browse to the index page and the make
  # Creates the model pages under a subdirectory titled by make
  def write_model(make, model, cameras)
    @title = make + ' - ' + model
    @make = make

    @thumbnail_urls = cameras.map do |camera|
      camera[:image_url]
    end

    # Create the make subdirectory if it doesn't exist already
    make_dir = "#{@out_dir}/#{sanitize_filename(make)}"
    Dir.mkdir(make_dir) unless File.exist?(make_dir)

    model_page = "#{make_dir}/#{sanitize_filename(model)}.html"
    File.open(model_page, 'w') do |f|
      template = File.open("templates/model.html.erb").read
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

  # Returns a unique list of makes of the cameras as an array of hashes like:
  # { make: "make", filename: "make_filename" }
  def extract_makes(cameras)
    cameras.map {|c| c[:make]}.uniq.map do |make|
      {
        make: make,
        filename: sanitize_filename(make)
      }
    end
  end

  # Returns a unique list of models of the cameras as an array of hashes like:
  # { model: "model", filename: "model_filename" }
  def extract_models(cameras)
    cameras.map {|c| c[:model]}.uniq.map do |model|
      {
        model: model,
        filename: sanitize_filename(model + '.html')
      }
    end
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
