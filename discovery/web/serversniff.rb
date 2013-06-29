require 'net/http'
require 'set'

#
# Check against webmax.
#
PlugMan.define :serversniff do
  author "Andrea Simoncini"
  version "0.1.0"
  extends({ :main => [:ip] })
  requires []
  extension_points []
  params({ :description => "Check against serversniff.net website" })

  def run(ip, opts = {})
    @hosts = Set.new

    begin
	  page=open("http://serversniff.net/hip-2.228.37.9").read
    rescue Exception => e
	  puts ":serversniff Error: #{e.inspect}"
      return @hosts
    end
    
	page.scan(/<td>Name<\/td><\/tr><tr><td> # [0-9]+ <\/td> <td><b> (.*?) <\/b><\/td>/).each do |domain|
      @hosts << { :domain => domain[0].to_s }
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
