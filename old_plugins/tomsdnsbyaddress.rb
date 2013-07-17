require 'open-uri'
require 'set'

#
# Check against tomsdns.
#

# Non sembra funzionare il servizio di tomsdns

PlugMan.define :tomsdnsbyaddress do
  author "Alessandro Tanasi"
  version "0.2.1"
  extends({ :main => [:ip] })
  requires []
  extension_points []
  params({ :description => "Check against tomsdns" })

  def run(ip, opts = {})
    @hosts = Set.new
	#AAS motore di ricerca che non fa nient'altro che richiamare serversniff.net. TODO: da eliminare
	return @hosts

    begin
      page = open("http://www.tomdns.net/get_hostonip.php?target=#{ip}").read
    rescue
	  puts "Error in tomsdnsbyaddress"
      return @hosts
    end
    
    page.scan(/-->([\d\w\.-_\r\n]+)</).each do |urls|
      urls.to_s.split("\n").each do |url|
        @hosts << { :hostname => url.to_s }
		puts "Found results in tomsdnsbyaddress"
      end
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
