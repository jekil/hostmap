require 'open-uri'
require 'set'

#
# Check against RUS CERT-DB.
#
PlugMan.define :ruscertbyaddress do
  author "Alessandro Tanasi"
  version "0.2.1"
  extends({ :main => [:ip] })
  requires []
  extension_points []
  params({ :description => "Check against RUS CERT-DB" })

  def run(ip, opts = {})
    @hosts = Set.new

    begin
      page = open("http://www.bfk.de/bfk_dnslogger.html?query=#{ip}").read
	  #AAS modificata regular expression
      #page.scan(/\">([\d\w\.-_]+)<\/a><\/tt><\/td><td><tt>/).each do |url|
      page.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).scan(/<tr id="color[0-9]+"><td><tt><a href="http:\/\/www.bfk.de\/bfk_dnslogger.html\?query=.*?#result" rel="nofollow">(.*?)<\/a><\/tt><\/td>/).each do |url|
        @hosts << { :hostname => url[0].to_s } 
      end
    rescue Exception => e
	  puts ":ruscertbyaddress error: #{e.inspect}"
      return @hosts
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
