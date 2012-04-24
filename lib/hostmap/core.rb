# General
require 'constants'
require 'logging'
require 'exceptions'

# Managers
require 'plugin_manager'
require 'network/dns'

# Discovery
require 'discovery/host'

# Standard library
require 'ipaddr'


module Hostmap

  #
  # Hostmap engine.
  #
  class Engine
    
    #
    # Mixin to be included into all classes that needs to share instantiated objects with the engine.
    #
    module Shared
  
      #
      # A reference to this instantiated engine.
      #
      attr_accessor :engine  
    end

    #
    # Creates an instance of the hostmap engine.
    #
    def initialize(opts={})
      # Load logger
      Hostmap::HLogger.new(opts)
      # If maltego output is selected never show anything
      if opts['printmaltego']
        #$LOG.level = HLogger::ERROR
      end

      $LOG.debug "Initializing hostmap engine."
      self.opts = opts

      # Configure DNS adapter.
      if opts['dns']
        dns = opts['dns'].gsub(/\s/, '').split(',')
        Hostmap::Network::Dns.configure(dns)
      else
        Hostmap::Network::Dns.configure(nil)
      end

    end

    #
    # Runs a  discovery as configured via options.
    #
    def run
      # Lists all plugins
      if self.opts['list']
        self.plugins = Hostmap::Managers::PluginManager.new(self)
        puts "Plugins by IP (gets an IP addess as input)"
        plugins.plugins_by_ip().each {|k,v| puts "\t#{v.info[:name]}"}
        puts "Plugins by domain (gets a domain as input)"
        plugins.plugins_by_domain().each {|k,v| puts "\t#{v.info[:name]}"}
        puts "Plugins by NS (gets a name server as input)"
        plugins.plugins_by_ns().each {|k,v| puts "\t#{v.info[:name]}"}
        puts "Plugins by hostname (gets an hostname addess as input)"
        plugins.plugins_by_hostname().each {|k,v| puts "\t#{v.info[:name]}"}
        return
      end
      # Run a single plugin
      if self.opts['plugin']
        # Input check
        if !self.opts['target']
          raise Hostmap::Exception::TargetError, "missing target value."
        end
        # Run plugin
        self.plugins = Hostmap::Managers::PluginManager.new(self)
        # Search plugin
        plugin = nil
        self.plugins.plugins_all.each {|k,v|
          if v.info[:name].downcase == self.opts['plugin'].downcase
            plugin = v
          end
         }
        self.plugins.start_once(plugin, self.opts['target'])
        return
      else
        # Validate options
        begin
          IPAddr.new(opts['target'])
        rescue
          raise Hostmap::Exception::TargetError, "isn't an IP address."
        end
        
        self.plugins = Hostmap::Managers::PluginManager.new(self)
        $LOG.debug "Running discovery engine."
        self.host_discovery = Hostmap::Discovery::HostMapping.new(self)
        self.host_discovery.run
      end
    end

    #
    # Stops a discovery.
    #
    def stop
      $LOG.debug "Stopping discovery engine."
      self.host_discovery.stop
    end

    #
    # The engine instance's plugin manager.
    #
    attr_reader   :plugins
    #
    # Configuration options
    #
    attr_reader :opts
    #
    # Host discovery instance.
    #
    attr_reader   :host_discovery
    
    protected

    attr_writer   :plugins # :nodoc:
    attr_writer   :opts # :nodoc:
    attr_writer   :host_discovery # :nodoc:
    
  end
end