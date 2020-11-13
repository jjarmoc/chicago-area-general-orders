#!/usr/bin/env ruby

require 'json'
require 'geocoder'

class Municipality
	def initialize(path)
		@path = path
		@state, @city = @path.split("/")
		@latitude, @longitude = Geocoder.search(self.address).first.coordinates
		@files = Dir.glob(@path + "/*")
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
            files: @files
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