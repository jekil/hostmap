require 'open-uri'
require 'set'
require 'plugins'

#
# Check against dnshistory.org.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :domain,
      :description => "Check against dnshistory.org."
    }
  end

  def execute(domain, opts = {})
    begin
      page = open("http://dnshistory.org/browsedomains/#{domain}.").read
    rescue Exception
      return @res
    end
    
    page.scan(/\.">(.*?)\.<\/a><br \/>/).each do |url|
      # NOTE: This check can enumerate ns, mx, cname, and other records, for the moment we report all as possible hostnames.
      @res << { :hostname => url.to_s }
    end

    return @res
  end
end
