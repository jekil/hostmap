require 'open-uri'
require 'uri'
require 'set'

#
# Check against microsoft Bing using developer API key.
#
PlugMan.define :bingapibyaddress do
  author "Alessandro Tanasi"
  version "0.3"
  extends({ :main => [:ip] })
  requires []
  extension_points []
  params({ :description => "Check against Bing using API" })

  def run(ip, opts = {})
	#puts "BingApiByAddress started"
    @hosts = Set.new

    # Skip check if without API key
    return @hosts if !opts['bingApiKey']

    #bingApiKey2="uI1pIkWj+LY2FRwPgCPXtDGCJJeAc3RfNB4b2mbt3Vw"

    #url="https://api.datamarket.azure.com/Bing/SearchWeb/Web?Query=%27#{ip}%27&skip=#{offset}"

    # Go!
    Range.new(0,1000).step(50) do |offset|
      begin
		#AAS la ricerca tira fuori URL impensabili -> TODO: da ricontrollare 
        #page = open("https://api.datamarket.azure.com/Bing/SearchWeb/Web?Query=%27#{ip}%27&$skip=#{offset}",:http_basic_authentication=>['',opts['bingApiKey']]).read
		page=open("https://api.datamarket.azure.com/Bing/Search/v1/Web?Query=%27ip%3A%20#{ip}%27&$skip=#{offset}",:http_basic_authentication=>[opts['bingApiKey'],opts['bingApiKey']]).read
        page.scan(/<d:Url m:type="Edm.String">(.*?)<\/d:Url>/).each do |arr_url|
          # Il page.scan non fa un array di stringhe, ma un array di array di stringhe.
          # Nelle prove che ho fatto nell array interno vi era solo un elemento con la URI in 
          # posizione 0, ma è da verificare sulle API
		  #$LOG.debug "Found new URL #{url.to_s}"
          url=arr_url[0]
          @hosts << { :hostname => URI.parse(url.to_s).host }
		  @hosts << { :bingurl => url.to_s }
        end
      rescue Exception => e
		if e.to_s == "Timeout::Error"
			$LOG.debug "Timeout for :bingapibyaddress plugin"
			return @hosts
		else
			puts "BingApiPlugin Exception #{e.inspect}"   #Ogni tanto da un errore in maniera abbastanza random
		end

        next        
      end
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
