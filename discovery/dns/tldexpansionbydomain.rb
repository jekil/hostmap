require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/rr'
require 'set'

#
# Check with DNS TLD expansion.
#
PlugMan.define :tldexpansionbydomain do
  author "Alessandro Tanasi"
  version "0.2.1"
  extends({ :main => [:domain] })
  requires []
  extension_points []
  params({ :description => "Check with DNS TLD expansion." })

  def run(domain, opts = {})
    hosts = Set.new

    # Configuration check
    if ! opts['dnsexpansion']
      $LOG.warn "Skipping DNS TLD expansion because it is disabled from command line"
      return hosts
    end

    # Initialization
    if opts['dns']
      dns = opts['dns'].gsub(/\s/, '').split(',')
      res = Net::DNS::Resolver.new(:nameserver => dns)
    else
      res = Net::DNS::Resolver.new
    end
    
    # Load TLD list
    if ! $TLD
      $TLD = File.open(HostMap::TLDFILE, "r").read
    end
    
    # Get domain name
    domain = HostMap::Utils.exclude_tld(domain)

    threads = []
    counter = 0

    # Brute force
    $TLD.each("\n") do |tld|
      # Skip comments
      if tld =~ /^#/
        next
      end
      
      # Sanitize
      tld = tld.chomp

      # Resolve
      if counter < 10
        threads << Thread.new {
          begin
            res.query("#{domain}.#{tld}").answer.each do |rr|
              # TODO: add this and report without check_host
              if rr.class == Net::DNS::RR::A
                if rr.address==IPAddr.new(opts['target'])
                  hosts << { :domain => "#{domain}.#{tld}" }
                end
              end
            end
          rescue Net::DNS::Resolver::NoResponseError
            nil
          rescue
            $LOG.debug "PLugin #{__FILE__} get a unhandled exception #{$!}"
          end
        }
        counter += 1
      else
        sleep(0.01) and threads.delete_if {|thr| not thr.alive? } while not threads.empty?
        counter = 0
     end

    end

    threads.delete_if {|thr| not thr.alive?} while not threads.empty?
    return hosts
  end
end