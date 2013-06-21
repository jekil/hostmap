require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/rr'
require 'set'
require 'timeout'

#
# Check with DNS TLD expansion.
#
PlugMan.define :tldexpansionbydomain do
  author "Alessandro Tanasi"
  version "0.2.2"
  extends({ :main => [:domain] })
  requires []
  extension_points []
  params({ :description => "Check with DNS TLD expansion." })

  def run(domain, opts = {})
    @hosts = Set.new

    # Configuration check
    if ! opts['dnsexpansion']
      $LOG.warn "Skipping DNS TLD expansion because it is disabled from command line"
      return @hosts
    end

    # Initialization
    if opts['dns']
      dns = opts['dns'].gsub(/\s/, '').split(',')
      res = Net::DNS::Resolver.new(:nameserver => dns)
    else
      res = Net::DNS::Resolver.new
    end

    # Silence net-dns logger
    res.log_level = Net::DNS::UNKNOWN
    
    # Load TLD list
    if ! $TLD
      $TLD = File.open(Hostmap::TLDFILE, "r").read
    end
    
    # Get domain name
    domain = Hostmap::Utils.exclude_tld(domain)

    # Brute force
    $TLD.split("\n").each do |tld|
      # Skip comments
      if tld =~ /^#/
        next
      end
      
      # Sanitize
      tld = tld.chomp

      # Resolve
      begin
        res.query("#{domain}.#{tld}").answer.each do |rr|
          # TODO: add this and report without check_host
          if rr.class == Net::DNS::RR::A
            if rr.address==IPAddr.new(opts['target'])
              @hosts << { :domain => "#{domain}.#{tld}" }
            end
          end
        end
      rescue Timeout::Error
        timeout()
      rescue Exception => e
        next
      end
    end

    return @hosts
  end

  def timeout
    return @hosts
  end
end