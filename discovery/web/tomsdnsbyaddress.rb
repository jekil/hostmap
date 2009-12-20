require 'open-uri'
require 'set'

#
# Check against tomsdns.
#
PlugMan.define :tomsdnsbyaddress do
  author "Alessandro Tanasi"
  version "0.2.1"
  extends({ :main => [:ip] })
  requires []
  extension_points []
  params({ :description => "Check against tomsdns" })

  def run(ip, opts = {})
    @hosts = Set.new

    begin
      page = open("http://www.tomdns.net/get_hostonip.php?target=#{ip}").read
    rescue
      return @hosts
    end
    
    page.scan(/-->([\d\w\.-_\r\n]+)</).each do |urls|
      urls.to_s.split("\n").each do |url|
        @hosts << { :hostname => url.to_s }
      end
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
