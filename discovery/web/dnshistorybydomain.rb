require 'open-uri'
require 'set'

#
# Check against dnshistory.org.
#
PlugMan.define :dnshistorybydomain do
  author "Alessandro Tanasi"
  version "0.2.2"
  extends({ :main => [:domain] })
  requires []
  extension_points []
  params({ :description => "Check against dnshistory.org" })

  def run(domain, opts = {})
    @hosts = Set.new

    begin
      page = open("http://dnshistory.org/browsedomains/#{domain}.").read
    rescue Exception
      return @hosts
    end
    
    page.scan(/\.">(.*?)\.<\/a><br \/>/).each do |url|
      # NOTE: This check can enumerate ns, mx, cname, and other records, for the moment we report all as possible hostnames.
      @hosts << { :hostname => url.to_s }
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
