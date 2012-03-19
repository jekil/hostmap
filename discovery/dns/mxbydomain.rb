require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/rr'
require 'set'
require 'network/dns'
require 'plugins'

#
# Check with MX dns query.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "MXByDomain",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :domain,
      :description => "Return mail exchange servers for a domain."
    }
  end

  def execute(domain, opts = {})
    begin
      Hostmap::Network::Dns.query(domain, Net::DNS::MX).answer.each do |rr|
        if rr.class == Net::DNS::RR::MX
          @res << { :mx => rr.exchange.gsub(/\.$/,'') }
        end
      end
    rescue
      return @res
    end
    
    return @res
  end
end
