require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/rr'
require 'set'

#
# Check with MX dns query.
#
PlugMan.define :mxbydomain do
  author "Alessandro Tanasi"
  version "0.2.0"
  extends({ :main => [:domain] })
  requires []
  extension_points []
  params({ :description => "Return mail exchange servers for a domain." })

  def run(domain, opts = {})
    mx = Set.new

    if opts['dns']
      dns = opts['dns'].gsub(/\s/, '').split(',')
      res = Net::DNS::Resolver.new(:nameserver => dns)
    else
      res = Net::DNS::Resolver.new
    end

    res.query(domain, Net::DNS::MX).answer.each do |rr|
      if rr.class == Net::DNS::RR::MX
        mx << { :mx => rr.exchange.gsub(/\.$/,'') }
      end
    end
    
    return mx
  end
end
