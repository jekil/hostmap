require 'open-uri'
require 'set'
require 'plugins'

#
# Check against tomsdns.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "TomsdnsByAddress",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :ip,
      :description => "Check against tomsdns."
    }
  end

  def execute(ip, opts = {})
    begin
      page = open("http://www.tomdns.net/get_hostonip.php?target=#{ip}").read
    rescue
      return @res
    end
    
    page.scan(/-->([\d\w\.-_\r\n]+)</).each do |urls|
      urls.to_s.split("\n").each do |url|
        @res << { :hostname => url.to_s }
      end
    end

    return @res
  end
end
