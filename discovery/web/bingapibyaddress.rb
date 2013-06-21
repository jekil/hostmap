require 'open-uri'
require 'uri'
require 'set'

#
# Check against microsoft Bing using developer API key.
#
PlugMan.define :bingapibyaddress do
  author "Alessandro Tanasi"
  version "0.3"
  extends({ :main => [:ip] })
  requires []
  extension_points []
  params({ :description => "Check against Bing using API" })

  def run(ip, opts = {})
    @hosts = Set.new

    # Skip check if without API key
    return @hosts if !opts['bingApiKey']

    # Go!
    Range.new(0,1000).step(50) do |offset|
      begin
        page = open("http://api.search.live.net/xml.aspx?Appid=#{opts['bingApiKey']}&query=ip:#{ip}&sources=web&web.count=50&web.offset=#{offset}").read
        page.scan(/<web:Url>(.*?)<\/web:Url>/).each do |url|
          @hosts << { :hostname => URI.parse(url.to_s).host }
        end
      rescue Exception
        next
      end
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
