require 'set'
require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/header'
require 'net/dns/rr'
require 'network/dns'
require 'plugins'


#
# Try to do an axfr zone transfer. This can be noted as an attack by sysadmins.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "AXFRByDomain",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :domain,
      :description => "Try to do an axfr zone transfer."
    }
  end

  def execute(domain, opts = {})
    # Configuration check
    if opts['onlypassive']
      $LOG.warn "Skipping DNS Zone transfer because it is enabled only passive checks."
      return @res
    end
    if ! opts['dnszonetransfer']
      $LOG.warn "Skipping DNS Zone transfer because it is disabled by default, you must enable it from from command line."
      return @res
    end

    $LOG.debug "Zone transfer check enabled."

    ip = nil
    ns = nil

    # Get the name server for the domain
    begin
      Hostmap::Network::Dns.query(domain, Net::DNS::NS).answer.each do |rr|
        ns = rr.nsdname.gsub(/.$/, '')
      end
    rescue Exception
      return @res
    end

    return @res if ns.nil?


    # Silence net-dns logger
    @resolver.log_level = Net::DNS::UNKNOWN

    # Get nameserver for the domain
    Hostmap::Network::Dns.query(ns).answer.each do |rr|
      if rr.class == Net::DNS::RR::A
        ip = rr.address
      end
      @resolver = Net::DNS::Resolver.new(:nameservers => ip.to_s)
    end

    return @res if ip.nil?
    
    # Set logging level to avoid messages generated to the use of TCP AXFR request
    @resolver.log_level = Net::DNS::ERROR
    
    # Perform transfer
    begin
      zone = @resolver.axfr(domain)
    rescue Exception
      return @res
    end

    # If the rcode is NOERROR
    if zone.header.rCode.code == 0
      
      $LOG.warn "Domain #{domain} served by name server #{ip} is vulnerable to zone transfer."

      zone.answer.each do | rr |
        # This is a really shitly if structure, but switch doesen't seem to work as expected
        if rr.class == Net::DNS::RR::A
          @res << { :hostname => rr.name.gsub(/.$/, '') }
        end
        if rr.class == Net::DNS::RR::NS
          @res << { :ns => rr.nsdname.gsub(/.$/, '') }
        end
        if rr.class == Net::DNS::RR::MX
          @res << { :mx => rr.exchange.gsub(/.$/, '') }
        end
        # TODO: add cname
      end
    end

    return @res
  end
end
