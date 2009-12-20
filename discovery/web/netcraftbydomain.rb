require 'open-uri'
require 'set'

#
# Check against netcraft.
#
PlugMan.define :netcraftbydomain do
  author "Alessandro Tanasi"
  version "0.2.1"
  extends({ :main => [:domain] })
  requires []
  extension_points []
  params({ :description => "Check against Netcraft" })

  def run(domain, opts = {})
    @hosts = Set.new

    begin
      page = open("http://searchdns.netcraft.com/?restriction=site+ends+with&host=#{domain}").read
    rescue
      return @hosts
    end
    
    page.scan(/uptime.netcraft.com\/up\/graph\/\?host=(.*?)\">/).each do |url|
      @hosts << { :hostname => url.to_s }
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
