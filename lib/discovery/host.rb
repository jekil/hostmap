require 'set'
require 'net/dns/resolver'
require 'net/dns/packet'
require 'net/dns/rr'
require 'ipaddr'
require 'rexml/document'
require 'utils'
load 'core.rb'


module Hostmap

  #
  # Provides discovery functionalities.
  #
  module Discovery

    #
    # Discovery based on host.
    #
    module HostDiscovery

      #
      # Host Mapping
      #
      class HostMapping

        include Hostmap::Engine::Shared

        def initialize(engine)
          self.engine = engine
          # Initialize the target model
          @host = Host.new(self.engine.opts['target'])
          # Initialize the resolver used for results check
          if self.engine.opts['dns']
            dns = self.engine.opts['dns'].gsub(/\s/, '').split(',')
            @resolver = Net::DNS::Resolver.new(:nameserver => dns)
          else
            @resolver = Net::DNS::Resolver.new
          end
        end

        #
        # Runs the hostmapping.
        #
        def run
          self.engine.plugins.start(:ip, @host.ip, proc {stop})
        end

        #
        # Stops the hostmapping and prints results.
        #
        def stop
          puts "\n"
          if self.engine.opts['printmaltego']
            puts @host.to_maltego
          else
            puts @host.to_txt
          end
        end

        #
        # Report a job result from a running plugin
        #
        def report(results)
          results.each do |res|
            res.each do |key, value|
              case key
                when :hostname then self.report_hostname(value)
                when :domain then self.report_domain(value)
                when :mx then self.report_mx(value)
                when :ns then self.report_ns(value)
              end
            end
          end
        end

        protected

        #
        # Report a found hostname
        #
        def report_hostname(name)
          # Sanitize
          begin
            name = Hostmap::Utils.sanitize_fqdn(name)
          rescue Hostmap::Exception::EnumerationError
            return
          end

          # Skip if already present
          if @host.alias.include?(name)
            return
          end

          # Checks the enumerated result
          if self.engine.opts['paranoid']
            if check_host(name)
              @host.alias << name
            else
              return
            end
          else
            @host.alias << name
          end

          $LOG.info "Found new hostname #{name}"

          # Report the domain too
          domain = Hostmap::Utils.parse_domain(name)
          report_domain(domain)

          
          # Run plugins
          self.engine.plugins.run_hostname(name)
        end

        #
        # Report a found domain
        #
        def report_domain(name)
          # Sanitize
          begin
            name = Hostmap::Utils.sanitize_fqdn(name)
          rescue Hostmap::Exception::EnumerationError
            return
          end

          # Skip if already present
          if @host.domains.include?(name)
            return
          end

          $LOG.info "Found new domain #{name}"
          
          @host.domains << name

          # Check if the enumerated domain is also a virtual host
          report_hostname(name)

          # Run plugins
          self.engine.plugins.run_domain(name)
        end

        #
        # Report a found nameserver
        #
        def report_ns(name)
          # Sanitize
          begin
            name = Hostmap::Utils.sanitize_fqdn(name)
          rescue Hostmap::Exception::EnumerationError
            return
          end

          # Skip if already present
          if @host.ns.include?(name)
            return
          end

          $LOG.info "Found new nameserver #{name}"

          @host.ns << name

          # Check if the nameserver is runned by the target ip address
          report_hostname(name)

          # Run plugins
          self.engine.plugins.run_ns(name)
        end

        #
        # Report a found mail server
        #
        def report_mx(name)
          # Sanitize
          begin
            name = Hostmap::Utils.sanitize_fqdn(name)
          rescue Hostmap::Exception::EnumerationError
            return
          end

          # Skip if already present
          if @host.mx.include?(name)
            return
          end

          $LOG.info "Found new mail server #{name}"

          @host.mx << name

          # Check if the mail server is runned by the target ip address
          report_hostname(name)
        end

        protected

        #
        # Checks if an hostname match host ip via dns resolution.
        #
        def check_host(name)
          begin
            @resolver.query(name).answer.each do |rr|
              # TODO: add this and report without check_host
              #if rr.type == Net::DNS::RR::CNAME
              #  check_host(rr.cname.gsub(/.$/, ''))
              #end
              if rr.class == Net::DNS::RR::A
                if rr.address==IPAddr.new(self.engine.opts['target'])
                  return true
                end
              end
            end
          rescue Net::DNS::Resolver::NoResponseError
            $LOG.debug "No response from DNS server for hostname #{name}."
            return false
          rescue Timeout::Error
            return false
          rescue Exception
            $LOG.debug "Impossible to check hostname #{name} due to DNS server issue."
            return false
          end

          return false
        end
      end

      #
      # Host model
      #
      class Host

        def initialize(ip)
          @ip = ip
          @mx = Set.new
          @ns = Set.new
          @alias = Set.new
          @domains = Set.new
        end

        #
        # Return host status as XML.
        #
        def to_xml
          doc = REXML::Document.new
          root = doc.add_element('host', { 'ip' => @ip, 'time' => Time.now})
          {'mail server' => @ms, 'name server' => @ns, 'domain' => @domains, 'hostname' => @alias}.each do |key, value|
            if value.nil?
              next
            end
            value.each do |val|
              node = root.add_element(key)
              node.text = val
            end
          end
          doc
        end

        #
        # Return host status in formatted text.
        #
        def to_txt(out = "")
          out << "Results for #{@ip}\n"
          out << "Served by name server (probably)\n"
          if @ns.size > 0
            @ns.each {|a| out << "\t#{a}\n" }
          else
            out << "No results found.\n"
          end
          out << "Served by mail exchange (probably)\n"
          if @mx.size > 0
            @mx.each {|a| out << "\t#{a}\n" }
          else
            out << "No results found.\n"
          end
          #out << "Part of domain (probably)\n"
          #@domains.each {|a| out << "\t#{a}\n" }
          out << "Hostnames:\n"
          if @alias.size > 0
            @alias.each {|a| out << "\t#{a}\n" }
          else
            out << "No results found.\n"
          end
          out
        end

        #
        # Returns host status in Maltego format.
        #
        def to_maltego(out = "")
          out << "<MaltegoMessage>"
          out << "<MaltegoTransformResponseMessage>"
          out << "<Entities>"

          if @ns.size > 0
            @ns.each { |a|
              out << "<Entity Type=\"NSrecord\">"
              out << "<Value>#{a}</Value>"
              out << "<Weight>100</Weight>"
              out << "</Entity>"
            }
          end

          if @mx.size > 0
            @mx.each { |a|
              out << "<Entity Type=\"MXrecord\">"
              out << "<Value>#{a}</Value>"
              out << "<Weight>100</Weight>"
              out << "</Entity>"
            }
          end

          if @alias.size > 0
            @alias.each { |a|
              out << "<Entity Type=\"DNSName\">"
              out << "<Value>#{a}</Value>"
              out << "<Weight>100</Weight>"
              out << "</Entity>"
            }
          end

          out << "</Entities>"
          out << "<UIMessages>" 
          out << "</UIMessages>"
          out << "</MaltegoTransformResponseMessage>"
          out << "</MaltegoMessage>"
        end

        #
        # Host  IP address.
        #
        attr_reader :ip
        
        #
        # List of host mail exchanges servers.
        #
        attr_accessor :mx

        #
        # List of nameservers that handle names for this host.
        #
        attr_accessor :ns

        #
        # List of hostnames for this IP.
        #
        attr_accessor :alias

        #
        # List of domains for this host.
        #
        attr_accessor :domains
      end

    end

    #
    # Discovery based on more than one host.
    #
    module NetDiscovery
      # TODO: Future development.
    end

  end
end