# General
require 'constants'
require 'logging'
require 'exceptions'

# Managers
require 'plugin_manager'

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
        $LOG.level = HLogger::ERROR
      end

      $LOG.debug "Initializing hostmap engine."

      # Validate options
      begin
        IPAddr.new(opts['target'])
      rescue
        raise Hostmap::Exception::TargetError, "isn't an IP address."
      end
      self.opts = opts
      self.plugins = Hostmap::Managers::PluginManager.new(self)
    end

    #
    # Runs a  discovery as configured via options.
    #
    def run
      $LOG.debug "Running discovery engine."
      self.host_discovery = Hostmap::Discovery::HostDiscovery::HostMapping.new(self)
      self.host_discovery.run
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