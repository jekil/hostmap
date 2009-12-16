require 'net/dns/resolver'
require 'set'

#
# Check with NS dns query.
#
PlugMan.define :nsbydomain do
  author "Alessandro Tanasi"
  version "0.2.0"
  extends({ :main => [:domain] })
  requires []
  extension_points []
  params({ :description => "Return name servers for a domain." })

  def run(domain, opts = {})
    ns = Set.new

    if opts['dns']
      dns = opts['dns'].gsub(/\s/, '').split(',')
      res = Net::DNS::Resolver.new(:nameserver => dns)
    else
      res = Net::DNS::Resolver.new
    end

    res.query(domain, Net::DNS::NS).answer.each do |rr|
      if rr.class == Net::DNS::RR::NS
        ns << { :ns => rr.nsdname.gsub(/\.$/,'') }
      end
    end

    return ns
  end
end
