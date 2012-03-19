require 'open-uri'
require 'set'
require 'plugins'

#
# Check against RUS CERT-DB.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :ip,
      :description => "Check against RUS CERT-DB."
    }
  end

  def execute(ip, opts = {})
    begin
      page = open("http://www.bfk.de/bfk_dnslogger.html?query=#{ip}").read
    rescue
      return @res
    end

    page.scan(/\">([\d\w\.-_]+)<\/a><\/tt><\/td><td><tt>/).each do |url|
      @res << { :hostname => url.to_s }
    end

    return @res
  end
end
