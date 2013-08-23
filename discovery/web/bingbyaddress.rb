require 'open-uri'
require 'uri'
require 'set'
require 'plugins'

#
# Check against Bing.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "BingByAddress",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :ip,
      :description => "Check against Bing."
    }
  end

  def execute(ip, opts = {})
    # Skip check if with API key
    if opts['bingApiKey']
      return @res
    end

    begin
      page = open("http://www.bing.com/search?q=ip:#{ip}").read
    rescue
      return @res
    end

    page.scan(/<h3><a href=\"(.*?)\" /).each do |url|
      begin
        @res << { :hostname => URI.parse(url.to_s).host }
      rescue
        next
      end
    end

    return @res
  end
end
