require 'net/dns'

module Hostmap
  module Network

    #
    # Net-dns adapter.
    #
    class Dns
      def self.configure(dns=nil)
        if dns
          @@resolver = Net::DNS::Resolver.new(:nameserver => dns)
        else
          @@resolver = Net::DNS::Resolver.new
        end
        # Silence logger.
        @@resolver.log_level = Net::DNS::UNKNOWN
      end

      def self.query(query, type=nil)
        if type
          @@resolver.search(query, type)
        else
          @@resolver.search(query)
        end
      end
    end

  end
end