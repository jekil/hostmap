require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/rr'
require 'set'

#
# Check with reverse dns query.
#
PlugMan.define :hostbyaddress do
  author "Alessandro Tanasi"
  version "0.2.1"
  extends({ :main => [:ip] })
  requires []
  extension_points []
  params({ :description => "Return hostname with reverse DNS (PTR) query." })

  def run(ip, opts = {})
    hosts = Set.new
    
    if opts['dns']
      dns = opts['dns'].gsub(/\s/, '').split(',')
      res = Net::DNS::Resolver.new(:nameserver => dns)
    else
      res = Net::DNS::Resolver.new
    end

    # Set logging level to avoid messages generated to the automatic use of PTR request
    res.log_level = Net::DNS::ERROR

    addr = IPAddr.new(ip)

    begin
      res.query(addr).answer.each do |rr|
        if rr.class == Net::DNS::RR::PTR
          hosts << { :hostname => rr.ptr.gsub(/\.$/,'') }
        end
      end
    rescue
      nil
    end

    return hosts
  end
end
