# Redbubble Challenge Solution

A script to parse EXIF data and produce a navigable HTML tree with the photos
ordered by camera make and model.

An example of the output looks like this:

```
OUT_DIRECTORY
├── Canon
│   ├── Canon_EOS_20D.html
│   ├── Canon_EOS_400D_DIGITAL.html
│   └── index.html
├── FUJIFILM
│   ├── FinePix_S6500fd.html
│   └── index.html
├── FUJI_PHOTO_FILM_CO.__LTD.
│   ├── SLP1000SE.html
│   └── index.html
├── LEICA
│   ├── D-LUX_3.html
│   └── index.html
├── NIKON_CORPORATION
│   ├── NIKON_D80.html
│   └── index.html
├── Panasonic
│   ├── DMC-FZ30.html
│   └── index.html
└── index.html
```

## Installation

1. Ruby 2.2 or later is recommended for this project (although it will probably work with 1.9.3 and up)
2. Make sure you have bundler with `gem install bundler`
3. Run `bundle install` in the root dir. This project requires nokogiri, if you have problems installing it please check [the documentation.](http://www.nokogiri.org/tutorials/installing_nokogiri.html)

## Usage

Run using `solution.rb` in the project root.

example run:

`ruby solution.rb ./resources/works.xml ./_html`

## License

MIT
