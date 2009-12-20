require 'open-uri'
require 'set'

#
# Check against RUS CERT-DB.
#
PlugMan.define :robtexbyaddress do
  author "Alessandro Tanasi"
  version "0.2.1"
  extends({ :main => [:ip] })
  requires []
  extension_points []
  params({ :description => "Check against Robtex" })

  def run(ip, opts = {})
    @hosts = Set.new

    begin
      page = open("http://www.robtex.com/ip/#{ip}.html").read
    rescue
      return @hosts
    end

    page.scan(/\" >([\w\-\_\.]+)<\/a><\/td><td/).each do |url|
      @hosts << { :hostname => url.to_s }
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
