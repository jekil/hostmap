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
    @hosts = Set.new

    # Skip check if without API key
    return @hosts if !opts['bingApiKey']

    #bingApiKey2="uI1pIkWj+LY2FRwPgCPXtDGCJJeAc3RfNB4b2mbt3Vw"

    #url="https://api.datamarket.azure.com/Bing/SearchWeb/Web?Query=%27#{ip}%27&skip=#{offset}"

    # Go!
    Range.new(0,1000).step(50) do |offset|
      begin
        #puts offset
        #puts opts['bingApiKey']
        #page = open("https://api.datamarket.azure.com/Bing/Search/v1/Composite?Appid=#{bingApiKey}&query=ip:#{ip}&sources=web&web.count=50&web.offset=#{offset}").read
        #page = open("http://api.search.live.net/xml.aspx?Appid=#{opts['bingApiKey']}&query=ip:#{ip}&sources=web&web.count=50&web.offset=#{offset}").read
        #page = open(url,:http_basic_authentication=>['',bingApiKey2]).read
        #page = open("https://api.datamarket.azure.com/Bing/SearchWeb/Web?Query=%27#{ip}%27&$skip=#{offset.to_s}",:http_basic_authentication=>['',bingApiKey2]).read
        page = open("https://api.datamarket.azure.com/Bing/SearchWeb/Web?Query=%27#{ip}%27&$skip=#{offset}",:http_basic_authentication=>['',opts['bingApiKey']]).read
        #page = open("https://api.datamarket.azure.com/Bing/SearchWeb/Web?Query=%27#{ip}%27",:http_basic_authentication=>['',bingApiKey2]).read
        #puts "Pagina:\n"
        #puts page
        #page.scan(/<web:Url>(.*?)<\/web:Url>/).each do |url|
        page.scan(/<d:Url m:type="Edm.String">(.*?)<\/d:Url>/).each do |arr_url|
          # Il page.scan non fa un array di stringhe, ma un array di array di stringhe.
          # Nelle prove che ho fatto nell array interno vi era solo un elemento con la URI in 
          # posizione 0, ma è da verificare sulle API
          url=arr_url[0]
          @hosts << { :hostname => URI.parse(url.to_s).host }
        end
      rescue Exception
        puts "Errore"   #Ogni tanto da un errore in maniera abbastanza random
        next        
      end
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
