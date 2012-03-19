require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/rr'
require 'set'
require 'plugins'
require 'network/dns'

#
# Check with reverse dns query.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "AddressByHost",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :hostname,
      :description => "Return IP addreess with reverse DNS (A) query."
    }
  end

  def execute(name, opts = {})
    begin
      Hostmap::Network::Dns.query(name).answer.each do |rr|
        if rr.class == Net::DNS::RR::CNAME
          @res << { :hostname => rr.cname.chop }
        end
        if rr.class == Net::DNS::RR::A
          @res << { :ip => rr.address.to_s }
        end
      end
    rescue
      return @res
    end

    return @res
  end
end
