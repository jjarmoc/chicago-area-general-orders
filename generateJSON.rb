#!/usr/bin/env ruby
require 'json'
require 'geocoder'

class Municipality
	def initialize(path)
		@path = path
		@state, @city = @path.split("/")
		@latitude, @longitude = Geocoder.search(self.address).first.coordinates
		@pdfs = Dir.glob(@path + "/*.pdf").sort
		@links = Dir.glob(@path + "/links.json").map{|j| JSON.parse(File.read(j))["links"]}.flatten
	end

	def address
  		[@city, @state].compact.join(', ')
	end

	def city
		@city
	end

	alias_method :to_s, :city

	def as_json(options={})
        {
            city: @city,
            state: @state,
            path: @path,
            coords: [@longitude, @latitude],
            pdfs: @pdfs,
            links: @links
        }
    end

    def to_json(*options)
        as_json(*options).to_json(*options)
    end
end

# Build an array of municipalities
munis = Dir.glob("Illinois/*").map { |e| Municipality.new(e)}

# Write it to a file, sorted by city name.
File.write("municipalities.json", munis.sort_by(&:city).to_json)