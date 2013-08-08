require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/rr'
require 'set'
require 'timeout'
require 'network/dns'
require 'plugins'

#
# Check with DNS TLD expansion.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "TLDExpansionByDomain",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :domain,
      :description => "Check with DNS TLD expansion."
    }
  end

  def execute(domain, opts = {})
    
    # Configuration check
    if ! opts['dnsexpansion']
      $LOG.warn "Skipping DNS TLD expansion because it is disabled from command line"
      return @res
    end
    
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
        Hostmap::Network::Dns.query("#{domain}.#{tld}").answer.each do |rr|
          # TODO: add this and report without check_host
          if rr.class == Net::DNS::RR::A
            if rr.address==IPAddr.new(opts['target'])
              @res << { :domain => "#{domain}.#{tld}" }
            end
          end
        end
      rescue Timeout::Error
        raise Timeout::Error
      rescue Exception => e
		return @hosts
      end
    end

    return @res
  end
end
