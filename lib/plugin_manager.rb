require 'thread'
require 'timeout'
load 'core.rb' # NOTE: big fat note! Must use load, not require or you get a name error!
require 'PlugMan'

module Hostmap

  #
  # Managers and handlers.
  #
  module Managers

    #
    # Handles the plugins. Loading and running jobs.
    #
    class PluginManager 
  
      include Hostmap::Engine::Shared

      #
      # Creates a new plugin manager.
      #
      def initialize(engine)
        self.engine = engine
        # Load plugins.
        self.load
		@thread_list = []
        # Store plugin queue
        @queue = Queue.new                                                        
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

		@thread_list = []

        # Select the right plugin to start
        case type
          when :ip then self.run_ip(value)
        end
        
		sleep 3

        Thread.abort_on_exception=true

		#is_ok=true	

        loop do
          @res = []
          until @queue.empty?

            job = @queue.pop
            key = job.keys[0]
            value = job.values[0]
            $LOG.debug "Plugin #{key.name.inspect}, #{value}"
			# manage threads in a simple way
			begin 
			 @thread_list << Thread.new(key,value,self.engine.opts) { |key_thr,value_thr,opts_thr|
					Thread.new (Thread.current) { |main|
						sleep self.engine.opts['timeout'].to_i
              			while main.alive?
							$LOG.info "Plugin #{key_thr.name.inspect} stil alive -> I'm going to kill it"
                			main.raise Timeout::Error
							#@main_thr.kill
                			sleep 0.1
              			end
					}
            		$LOG.debug "Plugin #{key_thr.name.inspect} with target #{value_thr} started in thread"

				 	out = key_thr.run(value_thr, opts_thr)
            		$LOG.debug "Plugin #{key_thr.name.inspect} Output: #{set2txt(out)}"
					@res << out

		    		}
			rescue Exception => e
				puts "Exception in thread: #{e.inspect}"
			end
          end

          # Time wait
          @thread_list.each {|x| x.join}
          # Report
			
          @res.each { |r| self.engine.host_discovery.report(r) }

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
		#$LOG.debug "plugin #{plugin.name} enqueued"
        @queue << {plugin => input}
      end

      #
      # Stops all the plugins.
      #
      def stop_all
        $LOG.debug "Stopping all plugins."
        #TODO: kill threads
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

        # Start all the plugins
        PlugMan.start_all_plugins
      end

      #
      #  Converts a results Set to a printable string
      #
      def set2txt(out)
        txt = ''

        # If no results
        return "None" if out.nil?

        out.each { |result|
          result.each { |key, val|
            txt << "#{val} "
          }
        }

        # Return text string
        txt
      end

    end

  end

end
