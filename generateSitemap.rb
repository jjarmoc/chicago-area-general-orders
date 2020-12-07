require 'git'
require 'uri'

# Monkey patch to let me indent strings
class String
  def indent s = "\t"; gsub(/^/, s) end
end

class Sitemap
	HEADER = <<~END
	    <?xml version="1.0" encoding="UTF-8"?>
	    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
	  END
	FOOTER = "</urlset>"
	
	def initialize()
		@resources = []
	end
	
	def add_resource(file)
		@resources.append(Sitemap::Resource.new(file))
	end

	def add_resources(files)
		files.each{|x| self.add_resource(x) }
	end

	def urlset
		@resources.join()
	end

	def to_s
		"#{HEADER}#{self.urlset.indent}#{FOOTER}"
	end
end

class Sitemap::Resource
	BASE_URL = "https://jjarmoc.github.io/chicago-area-general-orders/"
	
	def initialize(path)
		@path = path
	end

	def mtime
		Git.open(Dir.pwd).log.object(@path).first.date
	end

	def lastmod
		self.mtime.strftime("%Y-%m-%dT%H:%M:%S%:z")
	end

	def uri
		# Parse the BASE_URL
		uri = URI.parse(BASE_URL)
		# split the @path, encode components and append to uri.path
		path, filename = File.split(@path)
		path = '' if path = '.'
		uri.path = uri.path + path.split("/").map{ |x| URI.encode(x)}.append(URI.encode_www_form_component(filename)).join("/") 
		# Return the resulting URI as a string
		uri.to_s
	end

	def to_s
		# Produce a Sitemap URL xml snippet for this Resource
		xml = <<~END
		  <url>
		    <loc>#{self.uri}</loc>
		    <lastmod>#{self.lastmod}</lastmod>
		  </url>
		END
	end
end

# Create the sitemap and add our resources
s = Sitemap.new()
s.add_resources(Dir.glob("*.html"))
s.add_resources(Dir.glob("**/*.pdf"))
File.write("sitemap.xml", s )

