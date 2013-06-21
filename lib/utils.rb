module Hostmap
  
  #
  # Common utility functions
  #
  module Utils
    
    #
    # Parse a fully qualified domain name and return a domain.
    #
    def self.parse_domain(fqdn)
      # Load in cache TLD list
      if $MTLD.nil?
        $MTLD = File.open(Hostmap::MTLDFILE, "r").read
      end

      # Check if it's a particular TLD
      $MTLD.split("\n").each do |tld|
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
      # Empty case
      if fqdn.nil? or fqdn == ''
        raise Hostmap::Exception::EnumerationError, "Trying to sanitize and empty string."
      end
      # Downcase
      fqdn = fqdn.downcase
      # If is an IP address raise exception
      if fqdn.match(/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/)
        raise Hostmap::Exception::EnumerationError, "Trying to sanitize an ip address: #{fqdn}."
      end
      # Check if is a FQDN
      if !fqdn.match(/^[a-zA-Z0-9\w\.-]+\.[a-zA-Z]+$/)
        raise Hostmap::Exception::EnumerationError, "Trying to sanitize a not valid FQDN string: #{fqdn}."
      end
      # Check nodes length
      fqdn.split('.').each do |node|
        raise Hostmap::Exception::EnumerationError, "Length over 63 chars: #{fqdn}." if node.size >= 63
      end
      return fqdn
    end

    #
    # Exclude a TLD from a fqdn
    #
    def self.exclude_tld(fqdn)
      # Load in cache TLD list
      if $MTLD.nil?
        $MTLD = File.open(Hostmap::MTLDFILE, "r").read
      end

      # Check if it's a particular TLD
      $MTLD.each("\n") do |tld|
        # Skip comments
        if fqdn =~ /^#/
          next
        end
        
        if fqdn =~ /#{tld.chomp}$/
          return fqdn.gsub(/\.#{tld.chomp}$/,'')
        end
      end
      foo = fqdn.split('.')
      foo.pop
      return foo.join('.')
    end
  end
end
