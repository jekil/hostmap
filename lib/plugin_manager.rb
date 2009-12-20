require 'thread'
load 'core.rb' # NOTE: big fat note! Must use load, not require or you get a name error!
require 'PlugMan'


module HostMap

  #
  # Managers and handlers.
  #
  module Managers

    #
    # Handles the plugins. Loading and running jobs.
    #
    class PluginManager 
  
      include HostMap::Engine::Shared

      #
      # Creates a new plugin manager.
      #
      def initialize(engine)
        self.engine = engine
        # Load plugins.
        self.load
        # Store plugin queue
        @queue = Queue.new
        @pool = []
        # Throw exceptions in threads
        Thread.abort_on_exception = true
        # Callback to call when execution is done
        @callback = nil
      end

      #
      # Runs all plugins that depends from an enumerated ip.
      #
      def run_ip(ip)
        PlugMan.registered_plugins[:main].do_group(:ip, ip, self)
      end

      #
      # Runs all plugins that depends from an enumerated domain.
      #
      def run_domain(name)
        PlugMan.registered_plugins[:main].do_group(:domain, name, self)
      end

      #
      # Runs all plugins that depends from an enumerated nameserver.
      #
      def run_ns(name)
        PlugMan.registered_plugins[:main].do_group(:ns, name, self)
      end

      #
      # Runs all plugins that depends from an enumerated hostname.
      #
      def run_hostname(name)
        PlugMan.registered_plugins[:main].do_group(:hostname, name, self)
      end

      #
      # Start the engine suppling the parameters to start the first plugin.
      #
      def start(type, value, callback)
        # Set callback to later user
        @callback = callback

        # Select the right plugin to start
        case type
          when :ip then self.run_ip(value)
        end

        # Plugins loop
        loop do
          until @queue.empty?  do
            # Dequeue a plugin and run it
            @queue.deq.each { |k,v|
              # Creating a thread, running the plugin inside
              job = Thread.new do
                begin
                  out = k.run(v, self.engine.opts)
                  # Reports the result
                  self.engine.host_discovery.report(out)
                  $LOG.debug "Plugin: #{k.name.inspect} Output: #{set2txt(out)}"
                rescue
                  $LOG.debug "PLugin #{k.name.inspect} get a unhandled exception #{$!}"
                end
              end
            @pool << job
            }
          end

          # Consume long threads
          @pool.each { |th| th.join }
          # Break loop if no more plugins
          break if @queue.empty?
        end

        # Stop plugin manager
        stop_all
      end

      #
      # Enqueue a plugin to be runned.
      #
      def enq(plugin, input)
        @queue << {plugin => input}
      end

      #
      # Stops all the plugins.
      #
      def stop_all
        $LOG.debug "Stopping all plugins."
        @pool.each { |th| th.kill }
        PlugMan.stop_all_plugins()
        # Callback to discovery
        @callback.call
      end

      protected

      #
      # Load plugins from plugin directory
      #
      def load
        $LOG.debug "Loading plugins."

        # Load all the plugins
        PlugMan.load_plugins PLUGINDIR

        # Start all the pluins
        PlugMan.start_all_plugins
      end

      #
      #  Converts a results Set to a printable string
      #
      def set2txt(out)
        txt = ''

        out.each { |result|
          result.each { |key, val|
            txt << "#{val} "
          }
        }

        # If no results
        if out.length == 0
          txt = "None"
        end

        # Return text string
        txt
      end

    end
  end
end