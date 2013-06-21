require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/rr'
require 'set'

#
# Check with MX dns query.
#
PlugMan.define :mxbydomain do
  author "Alessandro Tanasi"
  version "0.2.1"
  extends({ :main => [:domain] })
  requires []
  extension_points []
  params({ :description => "Return mail exchange servers for a domain." })

  def run(domain, opts = {})
    @mx = Set.new

    if opts['dns']
      dns = opts['dns'].gsub(/\s/, '').split(',')
      res = Net::DNS::Resolver.new(:nameserver => dns)
    else
      res = Net::DNS::Resolver.new
    end

    # Silence net-dns logger
    res.log_level = Net::DNS::UNKNOWN

    begin
      res.query(domain, Net::DNS::MX).answer.each do |rr|
        if rr.class == Net::DNS::RR::MX
          @mx << { :mx => rr.exchange.gsub(/\.$/,'') }
        end
      end
    rescue
      nil
    end
    
    return @mx
  end

  def timeout
    return @mx
  end
end
