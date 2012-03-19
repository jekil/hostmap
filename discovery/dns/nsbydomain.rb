require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/rr'
require 'set'
require 'network/dns'
require 'plugins'

#
# Check with NS dns query.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "NSByDomain",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :domain,
      :description => "Return name servers for a domain."
    }
  end

  def execute(domain, opts = {})
    begin
      Hostmap::Network::Dns.query(domain, Net::DNS::NS).answer.each do |rr|
        if rr.class == Net::DNS::RR::NS
          @res << { :ns => rr.nsdname.gsub(/\.$/,'') }
        end
      end
    rescue
      return @res
    end

    return @res
  end
end
