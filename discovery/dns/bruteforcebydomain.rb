require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/rr'
require 'set'

#
# Check with DNS brute forcing.
#
PlugMan.define :bruteforcebydomain do
  author "Alessandro Tanasi"
  version "0.2.2"
  extends({ :main => [:domain] })
  requires []
  extension_points []
  params({ :description => "Check with DNS brute forcing." })

  def run(domain, opts = {})
    @hosts = Set.new

    # Configuration check
    if ! opts['dnsbruteforce']
      $LOG.warn "Skipping DNS bruteforce because it is disabled from command line"
      return @hosts
    end
    if opts['onlypassive']
      $LOG.warn "Skipping DNS bruteforce because it is enabled only passive checks"
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
    
    # False positives or wildcard domain preventive check with random query
    ["antani456", "t4p1occo", "evvivalafocaechilacosa"].each do |test|
      begin
        res.query("#{test}.#{domain}").answer.each do |rr|
          if rr.class == Net::DNS::RR::A
            if rr.address==IPAddr.new(opts['target'])
              $LOG.warn "Detected a wildward domain: #{domain}"
              return @hosts
            end
          end
        end
      rescue Exception
        return @hosts
      end
    end
    
    # Load brute force names list
    case opts['dnsbruteforcelevel']
      when "lite" then file = HostMap::DICTLITE
      when "full" then file = HostMap::DICTFULL
      when "custom" then file = HostMap::DICTCUSTOM
    end
    
    # Load dict
    if ! $HOSTDICT
      $HOSTDICT = File.open(file, "r").read
    end

    threads = []
    counter = 0
    
    # Brute force
    $HOSTDICT.each("\n") do |host|
      # Skip comments
      if host =~ /^#/
        next
      end
      
      # Sanitize
      host = host.chomp

      # Resolve
      begin
        res.query("#{host}.#{domain}").answer.each do |rr|
          # TODO: add this and report without check_host
          if rr.class == Net::DNS::RR::A
            if rr.address==IPAddr.new(opts['target'])
              @hosts << { :hostname => "#{host}.#{domain}" }
            end
          end
        end
      rescue Exception
        nil
      end
    end
    
    return @hosts
  end

  def timeout
    return @hosts
  end
end