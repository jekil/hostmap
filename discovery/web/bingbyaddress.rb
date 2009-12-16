require 'open-uri'
require 'uri'
require 'set'

#
# Check against Bing.
#
PlugMan.define :bingbyaddress do
  author "Alessandro Tanasi"
  version "0.2.0"
  extends({ :main => [:ip] })
  requires []
  extension_points []
  params({ :description => "Check against Bing." })

  def run(ip, opts = {})
    hosts = Set.new
    
    # Skip check if with API key
    if opts['bingApiKey']
      return hosts
    end

    begin
      page = open("http://www.bing.com/search?q=ip:#{ip}").read
    rescue OpenURI::HTTPError, Timeout::Error
      return hosts
    end

    page.scan(/<h3><a href=\"(.*?)\" /).each do |url|
      begin
        hosts << { :hostname => URI.parse(url.to_s).host }
      rescue URI::InvalidURIError
        next
      end
    end

    return hosts
  end
end
