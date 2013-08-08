require 'open-uri'
require 'uri'
require 'set'

#
# Check against gigablast.
#
PlugMan.define :gigablastbyaddress do
  author "Alessandro Tanasi"
  version "0.2.2"
  extends({ :main => [:ip] })
  requires []
  extension_points []
  params({ :description => "Check against gigablast." })

  def run(ip, opts = {})
    @hosts = Set.new

    begin
	  page=open("http://www.gigablast.com/search?q=ip:#{ip}&id=2986944357&rand=1372440063123").read
    rescue
      return @hosts
    end
    
	page.scan(/<a href=(.*?)\/><i>/).each do |url|
      begin
        @hosts << { :hostname => URI.parse(url[0].to_s).host }
      rescue
        next
      end
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
