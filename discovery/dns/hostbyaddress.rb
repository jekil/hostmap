require 'net/dns'
require 'set'
require 'plugins'
require 'network/dns'

#
# Check with reverse dns query.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "HostByAddress",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :ip,
      :description => "Return hostname with reverse DNS (PTR) query."
    }
  end

  def execute(ip, opts = {})

    addr = IPAddr.new(ip)

    begin
      Hostmap::Network::Dns.query(addr).answer.each do |rr|
        if rr.class == Net::DNS::RR::PTR
          @res << { :hostname => rr.ptr.gsub(/\.$/,'') }
        end
      end
    rescue
      return @res
    end

    return @res
  end
end
