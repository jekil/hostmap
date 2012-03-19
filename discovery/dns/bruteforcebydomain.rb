require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/rr'
require 'set'
require 'timeout'
require 'plugins'

#
# Check with DNS brute forcing.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "BruteForceByDomain",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :domain,
      :description => "Check with DNS brute forcing."
    }
  end

  def execute(domain, opts = {})

    # Configuration check
    if ! opts['dnsbruteforce']
      $LOG.warn "Skipping DNS bruteforce because it is disabled from command line"
      return @res
    end
    if opts['onlypassive']
      $LOG.warn "Skipping DNS bruteforce because it is enabled only passive checks"
      return @res
    end

    # Initialization
    if opts['dns']
      dns = opts['dns'].gsub(/\s/, '').split(',')
      @resolver = Net::DNS::Resolver.new(:nameserver => dns)
    else
      @resolver = Net::DNS::Resolver.new
    end
    @counter = 0

    # Silence net-dns logger
    @resolver.log_level = Net::DNS::UNKNOWN
    
    # False positives or wildcard domain preventive check with random query
    3.times do
      return @res if prev_check(domain)
    end
    
    # Load brute force names list
    case opts['dnsbruteforcelevel']
      when "lite" then file = Hostmap::DICTLITE
      when "full" then file = Hostmap::DICTFULL
      when "custom" then file = Hostmap::DICTCUSTOM
    end
    
    # Load dict
    if ! $HOSTDICT
      $HOSTDICT = File.open(file, "r").read
    end

    # Brute force
    $HOSTDICT.split("\n").each do |host|
      # Skip comments
      if host =~ /^#/
        next
      end
      
      # Sanitize
      host = host.chomp

      # Resolve
      begin
        @resolver.query("#{host}.#{domain}").answer.each do |rr|
          # TODO: add this and report without check_host
          if rr.class == Net::DNS::RR::A
            if rr.address==IPAddr.new(opts['target'])
              @res << { :hostname => "#{host}.#{domain}" }
              return Set.new if count(domain, true)
            else
              count(domain, false)
            end
          end
        end
      rescue Timeout::Error
        raise Timeout::Error
      rescue Exception => e
        next
      end
    end
    
    return @res
  end

  #
  # Preventive check to avoid false positives.
  #
  def prev_check(domain)
    test = (0...8).map{65.+(rand(25)).chr}.join
    begin
      @resolver.query("#{test}.#{domain}").answer.each do |rr|
        if rr.class == Net::DNS::RR::A
          if rr.address==IPAddr.new(opts['target'])
            $LOG.warn "Detected a wildcard domain: #{domain}"
            return true
          end
        end
      end
    rescue Exception
      return true
    end
    return false
  end

  def count(domain, status)
    if status
      @counter = @counter + 1
      if @counter >= 5
        return true if prev_check(domain)
      end
    else
      @counter = 0
      return false
    end
  end
end