require 'open-uri'
require 'uri'
require 'set'
require 'plugins'

#
# Check against microsoft Bing using developer API key.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "BingAPIByAddress",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :ip,
      :description => "Check against Bing using API."
    }
  end

  def execute(ip, opts = {})
    # Skip check if without API key
    return @res if !opts['bingApiKey']

    # Go!
    Range.new(0,1000).step(50) do |offset|
      begin
        page = open("http://api.search.live.net/xml.aspx?Appid=#{opts['bingApiKey']}&query=ip:#{ip}&sources=web&web.count=50&web.offset=#{offset}").read
        page.scan(/<web:Url>(.*?)<\/web:Url>/).each do |url|
          @res << { :hostname => URI.parse(url.to_s).host }
        end
      rescue Exception
        next
      end
    end

    return @res
  end
end
