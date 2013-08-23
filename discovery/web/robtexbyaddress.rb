require 'open-uri'
require 'set'
require 'plugins'

#
# Check against RUS CERT-DB.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "RobtexByAddress",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :ip,
      :description => "Check against Robtex."
    }
  end

  def execute(ip, opts = {})
    begin
      page = open("http://www.robtex.com/ip/#{ip}.html").read
    rescue
      return @res
    end

    page.scan(/\">([\w\-\_\.]+)<\/a><\/span><\/td><td/).each do |url|
      @res << { :hostname => url.to_s }
    end

    return @res
  end
end
