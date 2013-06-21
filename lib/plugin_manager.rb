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

        # Select the right plugin to start
        case type
          when :ip then self.run_ip(value)
        end
        
        # Plugins pool
        @pool = ThreadPool.new(self.engine.opts['timeout'].to_i, self.engine.opts['threads'].to_i)
        
        loop do
          @res = []
          until @queue.empty?
            job = @queue.pop
            key = job.keys[0]
            value = job.values[0]
            @pool.process {
              begin
                $LOG.debug "Plugin #{key.name.inspect} started"
                out = key.run(value, self.engine.opts)
                # Reports the result
                $LOG.debug "Plugin #{key.name.inspect} Output: #{set2txt(out)}"
                @res << out
              rescue Timeout::Error
                @res << key.timeout
                $LOG.warn "Plugin #{key.name.inspect} execution expired. Output: #{set2txt(out)}"
              rescue Exception
                $LOG.debug "Plugin #{key.name.inspect} got a unhandled exception #{$!}"
              end
            }
          end

          # Time wait
          @pool.join
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

        # Start all the pluins
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


    #
    # Handles a basic thread pool.
    #
    class ThreadPool

      #
      # Thread consumer.
      #
      class Worker
        def initialize(timeout, pool, block)
          Thread.abort_on_exception=true
          @main = Thread.new {
            @timer = Thread.new {
              sleep timeout
              while @main.alive?
                @main.raise Timeout::Error
                sleep 1
              end
            }
            begin
              block.call
            ensure
              @timer.kill if @timer.alive?
              pool.stop_worker(self)
            end
          }
        end
      end

      attr_accessor :max_size
      attr_reader :workers

      def initialize(timeout, max_size = 10)
        @max_size = max_size
        @timeout = timeout
        @workers = []
        @mutex = Mutex.new
      end

      #
      # Return the size of the current pool.
      #
      def size
        @workers.size
      end

      #
      # If the pool is busy.
      #
      def busy?
        !@workers.empty?
      end

      #
      # Wait to finish
      #
      def join
        while busy?
          sleep 1
        end
      end

      #
      # Runs a block
      #
      def process(&block)
        while true
          @mutex.synchronize do
            worker = create_worker(block)
            if worker
              return worker
            end
          end
          sleep 1
        end
      end

      #
      # Create a worker
      #
      def create_worker(block)
        return nil if @workers.size >= @max_size
        worker = Worker.new(@timeout, self, block)
        @workers << worker
        worker
      end

      #
      # Stops a running worker.
      #
      def stop_worker(worker)
        @workers.delete(worker)
      end
    end
  end
end