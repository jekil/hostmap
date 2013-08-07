require 'open-uri'
require 'set'
require 'digest/sha1'


#
# Check against netcraft.
#
PlugMan.define :netcraftbydomain do
  author "Alessandro Tanasi"
  version "0.2.1"
  extends({ :main => [:domain] })
  requires []
  extension_points []
  params({ :description => "Check against Netcraft" })

  def run(domain, opts = {})
    @hosts = Set.new

    # Netcraft per evitare query automatiche, alla prima richiesta manda un challenge cookie,
    # che va URL decodato, encodato in SHA1 e rispedito insieme a ogni richiesta.

    # Genero la prima richiesta
    begin
      page = open("http://searchdns.netcraft.com/?restriction=site+ends+with&host=#{domain}","Host" => "searchdns.netcraft.com","User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:20.0) Gecko/20100101 Firefox/20.0", "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "Accept-Language" => "en-US,en;q=0.5", "Accept-Encoding" => "gzip, deflate")
    rescue Exception => e
      puts ":netcraftbydomain error: #{e.inspect}"
      return @hosts
    end

    # Estraggo il challenge cookie
    to_encode=page.meta['set-cookie'].scan(/netcraft_js_verification_challenge=(.*);\ path=\//)[0][0]

    # Decodifico l'URL encoding ed eseguo un encoding SHA1
    encoded= Digest::SHA1.hexdigest URI.unescape(to_encode)

    # Eseguo la seconda richiesta con allegato il token challenge e il token encodato (più altri 
    # header per far si che mi scambi per un browser
    begin
      page = open("http://searchdns.netcraft.com/?restriction=site+ends+with&host=#{domain}","Host" => "searchdns.netcraft.com","User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:20.0) Gecko/20100101 Firefox/20.0", "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "Accept-Language" => "en-US,en;q=0.5", "Accept-Encoding" => "gzip, deflate","Cookie" => "netcraft_js_verification_challenge=#{to_encode};netcraft_js_verification_response=#{encoded}","Connection"=>"keep-alive")
    rescue Exception => e
      puts ":netcraftbydomain error: #{e.inspect}"
      return @hosts
    end


    page=page.read
    
    page.scan(/uptime.netcraft.com\/up\/graph\/\?host=(.*?)\">/).each do |url|
      @hosts << { :hostname => url[0].to_s }
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
