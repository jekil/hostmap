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
    rescue
      return @hosts
    end

    page.scan(/\">([\d\w\.-_]+)<\/a><\/tt><\/td><td><tt>/).each do |url|
      @hosts << { :hostname => url.to_s }
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
