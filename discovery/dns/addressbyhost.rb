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
      :name => "AddressByHost",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :hostname,
      :description => "Return IP addresses with reverse DNS (A) query."
    }
  end

  def execute(name, opts = {})
    puts 'start'
    puts name
    #begin
      a=Hostmap::Network::Dns.query(IPAddr.new(name))
      puts a
      a.answer.each do |rr|
        puts rr
        if rr.class == Net::DNS::RR::CNAME
          @res << { :hostname => rr.cname.chop }
        end
        if rr.class == Net::DNS::RR::A
          @res << { :ip => rr.address.to_s }
        end
      end
    #rescue
    #  return @res
    #end

    return @res
  end
end
