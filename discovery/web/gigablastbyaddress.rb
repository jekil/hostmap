require 'open-uri'
require 'uri'
require 'set'
require 'plugins'

#
# Check against gigablast.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "GigablastByAddress",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :ip,
      :description => "Check against gigablast."
    }
  end

  def execute(ip, opts = {})
    begin
      page = open("http://www.gigablast.com/search?n=100&q=ip:#{ip}").read
    rescue
      return @res
    end
    
    page.scan(/<a href=(.*?)><font /).each do |url|
      begin
        @res << { :hostname => URI.parse(url.to_s).host }
      rescue
        next
      end
    end

    return @res
  end
end
