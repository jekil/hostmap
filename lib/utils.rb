module HostMap
  
  #
  # Common utility functions
  #
  module Utils
    
    #
    # Parse a fully qualified domain name and return a domain.
    #
    def self.parse_domain(fqdn)
      # Load in cache TLD list
      if $TLD.nil?
        $TLD = File.open(HostMap::TLDFILE, "r").read
      end

      # Check if it's a particular TLD
      $TLD.each("\n") do |tld|
        # Skip comments
        if fqdn =~ /^#/
          next
        end

        if fqdn =~ /#{tld.chomp}$/
          foo = fqdn.gsub(".#{tld.chomp}", '')
          if foo.split(".").size >= 2
            return foo.split(".").slice(1,99).join(".") + ".#{tld.chomp}"
          else
            return foo + ".#{tld.chomp}"
          end
        end
      end

      # Check if we already have the domain or we must parse it
      if fqdn.split(".").size > 2
        return fqdn.split(".").slice(1,99).join(".")
      end
      if fqdn.split(".").size == 2
        return fqdn
      end
      # TODO: add exception
      raise
    end
    
    #
    # Sanitize a FQDN and throw an exception if it is an IP address.
    #
    def self.sanitize_fqdn(fqdn)
      fqdn = fqdn.downcase
      # If is and IP address raise exception
      if fqdn.match(/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/)
        raise HostMap::Exception::EnumerationError, fqdn
      else 
        return fqdn
      end
    end
  end
end