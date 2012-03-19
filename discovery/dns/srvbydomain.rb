require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/rr'
require 'set'
require 'network/dns'
require 'plugins'

#
# Check with DNS SRV brute forcing.
#
class HostmapPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :name => "SRVByDomain",
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :domain,
      :description => "Check with DNS SRV brute forcing."
    }
  end

  def execute(domain, opts = {})
    return @res

    # Configuration check
    if ! opts['dnssrvenum']
      $LOG.warn "Skipping DNS SRV enumeration because it is disabled from command line"
      return @hosts
    end

    # Load srv list
    if ! $SRV
      $SRV = File.open(file, "r").read
    end

    threads = []
    counter = 0
    
    # Brute force
    $SRV.each("\n") do |srv|
      # Skip comments
      if srv =~ /^#/
        next
      end
      
      # Sanitize
      srv = srv.chomp

      # Resolve
      if counter < 10
        threads << Thread.new {
          Hostmap::Network::Dns.query("#{srv}.#{domain}", Net::DNS::SRV).answer.each do |rr|
            # TODO: add this and report without check_host
            if rr.class == Net::DNS::RR::SRV
              puts rr.host
              if rr.host==IPAddr.new(opts['target'])
                @hosts << { :hostname => "#{rr.host.to_s}.#{domain}" }
              end
            end
          end
        }
        counter += 1
      else
        sleep(0.01) and threads.delete_if {|thr| not thr.alive? } while not threads.empty?
        counter = 0
     end

    end

    threads.delete_if {|thr| not thr.alive?} while not threads.empty?
    return @hosts
  end

  def timeout
    return @hosts
  end
end