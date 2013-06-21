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
      #page.scan(/\">([\d\w\.-_]+)<\/a><\/tt><\/td><td><tt>/).each do |url|
      page.force_encoding("ISO-8859-1").encode("utf-8", replace: nil).scan(/\">([\d\w\.-_]+)<\/a><\/tt><\/td>/).each do |url|
        #puts url.to_s
        @hosts << { :hostname => url[0].to_s } 
      #@hosts << "www.google.com"
      end
    rescue
      return @hosts
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
