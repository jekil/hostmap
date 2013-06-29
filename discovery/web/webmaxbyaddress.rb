require 'net/http'
require 'set'

#
# Check against webmax.
#
PlugMan.define :webmaxbyaddress do
  author "Alessandro Tanasi"
  version "0.2.0"
  extends({ :main => [:ip] })
  requires []
  extension_points []
  params({ :description => "Check against webmax website" })

  def run(ip, opts = {})
    @hosts = Set.new

	#AAS il motore di ricerca non restituisce risultati. TODO: da ricontrollare tra qualche giorno
	return @hosts

    begin
      #page = Net::HTTP.post_form(URI.parse('http://tools.web-max.ca/websitesonip.php'), {'ip' => ip, 'byip'=>'Search+by+specific+IP'})
      page = Net::HTTP.post_form(URI.parse('http://tools.web-max.ca/index.php'), {'ip' => ip, 'byip'=>'Search+by+specific+IP'})
    rescue
      return @hosts
    end
    
    page.body.scan(/\" target=\"_blank\">(.*?)<\/a>/).each do |domain|
      @hosts << { :domain => domain.to_s }
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
