require 'net/http'
require 'set'
require 'plugins'

#
# Check against webmax.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "WebmaxByAddress",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :ip,
      :description => "Check against webmax website."
    }
  end

  def execute(ip, opts = {})
    begin
      page = Net::HTTP.post_form(URI.parse('http://ip2web.web-max.ca/index.php'), {'ip' => ip, 'byip'=>'Search+by+specific+IP'})
    rescue
      return @res
    end
    
    page.body.scan(/\" target=\"_blank\">(.*?)<\/a>/).each do |domain|
      @res << { :domain => domain.to_s }
    end

    return @res
  end
end
