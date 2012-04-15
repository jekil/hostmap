require 'open-uri'
require 'set'
require 'plugins'

#
# Check against netcraft.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "NetcraftByDomain",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :domain,
      :description => "Check against Netcraft."
    }
  end

  def execute(domain, opts = {})
    begin
      page = open("http://searchdns.netcraft.com/?restriction=site+ends+with&host=#{domain}").read
    rescue
      return @res
    end
    
    page.scan(/uptime.netcraft.com\/up\/graph\/\?host=(.*?)\">/).each do |url|
      @res << { :hostname => url.to_s }
    end

    return @res
  end
end
