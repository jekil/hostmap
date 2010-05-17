require 'set'
require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/header'
require 'net/dns/rr'


#
# Try to do an axfr zone transfer. This can be noted as an attack by sysadmins.
#
PlugMan.define :axfrbydomain do
  author "Alessandro Tanasi"
  version "0.3"
  extends({ :main => [:domain] })
  requires []
  extension_points []
  params({ :description => "Try to do an axfr zone transfer." })

  def run(domain, opts = {})
    @hosts = Set.new

    # Configuration check
    if opts['onlypassive']
      $LOG.warn "Skipping DNS Zone transfer because it is enabled only passive checks."
      return @hosts
    end
    if ! opts['dnszonetransfer']
      $LOG.warn "Skipping DNS Zone transfer because it is disabled by default, you must enable it from from command line."
      return @hosts
    end

    $LOG.debug "Zone transfer check enabled."

    ip = nil
    ns = nil

    # Get the name server for the domain
    res = Net::DNS::Resolver.new
    begin
      res.query(domain, Net::DNS::NS).answer.each do |rr|
        ns = rr.nsdname.gsub(/.$/, '')
      end
    rescue Exception
      return @hosts
    end

    return @hosts if ns.nil?

    # Get name server ip
    if opts['dns']
      dns = opts['dns'].gsub(/\s/, '').split(',')
      @res = Net::DNS::Resolver.new(:nameserver => dns)
    else
      @res = Net::DNS::Resolver.new
    end

    # Silence net-dns logger
    res.log_level = Net::DNS::UNKNOWN

    # Get nameserver for the domain
    @res.query(ns).answer.each do |rr|
      if rr.class == Net::DNS::RR::A
        ip = rr.address
      end
      @res = Net::DNS::Resolver.new(:nameservers => ip.to_s)
    end

    return @hosts if ip.nil?
    
    # Set logging level to avoid messages generated to the use of TCP AXFR request
    @res.log_level = Net::DNS::ERROR
    
    # Perform transfer
    begin
      zone = @res.axfr(domain)
    rescue Exception
      return @hosts
    end

    # If the rcode is NOERROR
    if zone.header.rCode.code == 0
      
      $LOG.warn "Domain #{domain} served by name server #{ip} is vulnerable to zone transfer."

      zone.answer.each do | rr |
        # This is a really shitly if structure, but switch doesen't seem to work as expected
        if rr.class == Net::DNS::RR::A
          @hosts << { :hostname => rr.name.gsub(/.$/, '') }
        end
        if rr.class == Net::DNS::RR::NS
          @hosts << { :ns => rr.nsdname.gsub(/.$/, '') }
        end
        if rr.class == Net::DNS::RR::MX
          @hosts << { :mx => rr.exchange.gsub(/.$/, '') }
        end
        # TODO: add cname
      end
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end
