require 'open-uri'
require 'set'

#
# Check against dnshistory.org.
#
PlugMan.define :dnshistorybydomain do
  author "Alessandro Tanasi"
  version "0.2.2"
  extends({ :main => [:domain] })
  requires []
  extension_points []
  params({ :description => "Check against dnshistory.org" })

  def run(domain, opts = {})
    @hosts = Set.new

    begin
      page = open("http://dnshistory.org/dns-records/#{domain}.").read
    rescue Exception
      puts "Errore"
      return @hosts
    end

    #puts page
    
    #page.scan(/\.">(.*?)\.<\/a><br \/>/).each do |url|
      # NOTE: This check can enumerate ns, mx, cname, and other records, for the moment we report all as possible hostnames.
      #@hosts << { :hostname => url[0].to_s }
    #end


    page.scan(/MName:\ (.*?)<br\ \/>/).each do |url|
      @hosts << { :hostname => url[0].to_s }
    end

    page.scan(/RName:\ (.*?)<br\ \/>/).each do |url|
      @hosts << { :hostname => url[0].to_s }
    end

    page.scan(/[\d-]{10}\ ->\ [\d-]{10}.*<a\ href=".*">(.*?)<\/a><br\ \/>/).each do |url|
      @hosts << { :hostname => url[0].to_s }
    end

    #Chiedere a mauri per il record txt
    # Il report divide hostname, mx, ns...diversificando gli scan magari si può fare anche qui

    return @hosts
  end

  def timeout
    return @hosts
  end
end
