require 'thread'
require 'timeout'
load 'core.rb' # NOTE: big fat note! Must use load, not require or you get a name error!


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
        @loaded_plugins = {}
        self.load
        # Store plugin queue
        @queue = Queue.new
        # Callback to call when execution is done
        @callback = nil
      end

      #
      # List all plugins that depends by ip.
      #
      def plugins_by_ip
        return list_plugin(:ip)
      end

      #
      # List all plugins that depends by domain.
      #
      def plugins_by_domain
        return list_plugin(:domain)
      end

      #
      # List all plugins that depends by name server.
      #
      def plugins_by_ns
        return list_plugin(:ns)
      end

      #
      # List all plugins that depends by host name.
      #
      def plugins_by_hostname
        return list_plugin(:hostname)
      end
      
      #
      # List all plugins
      #
      def plugins_all
        return list_plugin(:all)
      end
      
      #
      # Runs all plugins that depends from an enumerated ip.
      #
      def run_ip(ip)
        plugins_by_ip.each do |file, plugin|
          enq(plugin, ip)
        end
      end

      #
      # Runs all plugins that depends from an enumerated domain.
      #
      def run_domain(name)
        plugins_by_domain.each do |file, plugin|
          enq(plugin, name)
        end
      end

      #
      # Runs all plugins that depends from an enumerated nameserver.
      #
      def run_ns(name)
        plugins_by_ns.each do |file, plugin|
          enq(plugin, name)
        end
      end

      #
      # Runs all plugins that depends from an enumerated hostname.
      #
      def run_hostname(name)
        plugins_by_hostname.each do |file, plugin|
          enq(plugin, name)
        end
      end
      
      def enq(plugin, input)
        @queue << {plugin => input}
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
            puts key.info[:name]
            value = job.values[0]
            @pool.process {
              begin
                $LOG.debug "Plugin #{key.info[:name]} started"
                out = key.execute(value, self.engine.opts)
                # Reports the result
                $LOG.debug "Plugin #{key.info[:name]} Output: #{set2txt(out)}"
                @res << out
              rescue Timeout::Error
                @res << key.timeout
                $LOG.warn "Plugin #{key.info[:name]} execution expired. Output: #{set2txt(out)}"
              rescue Exception
                $LOG.debug "Plugin #{key.info[:name]} got a unhandled exception #{$!}"
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
      
      def start_once(plugin, input)
        $LOG.info "Single plugin run mode."
        begin
          @res = []
          Timeout::timeout(self.engine.opts['timeout'].to_i) {
            begin
              $LOG.debug "Plugin #{plugin.info[:name]} started"
              out = plugin.execute(input, self.engine.opts)
              # Reports the result
              $LOG.info "Plugin #{plugin.info[:name]} Output: #{set2txt(out)}"
              @res << out
            rescue Exception
              $LOG.debug "Plugin #{plugin.info[:name]} got a unhandled exception #{$!}"
            end
          }
        rescue Timeout::Error
          @res << plugin.timeout
          $LOG.warn "Plugin #{plugin.info[:name]} execution expired. Output: #{set2txt(@res)}"
        end
        return @res
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
        Dir.glob("#{PLUGINDIR}/**/*.rb").each do |f|
          require f
          if defined?(HostmapPlugin)
            $LOG.debug "Parsing plugin: #{f}"
            @loaded_plugins[f] = HostmapPlugin.new
            Object.send(:remove_const, 'HostmapPlugin')
          end
        end
        $LOG.debug "Loaded #{plugins_by_ip.size + plugins_by_ns.size + plugins_by_domain.size + plugins_by_hostname.size} plugins" 
        $LOG.debug "Loaded #{plugins_by_ip.size} plugins depending from ip"
        $LOG.debug "Loaded #{plugins_by_domain.size} plugins depending from domain"
        $LOG.debug "Loaded #{plugins_by_ns.size} plugins depending from name server"
        $LOG.debug "Loaded #{plugins_by_hostname.size} plugins depending from hostname"
      end

      #
      # Lists plugins by type.
      #
      def list_plugin(type)
        list = {}
        @loaded_plugins.each do |file, instance|
          if instance.info[:require] == type
            list[file] = instance
          end
          if type == :all
            list[file] = instance
          end
        end
        return list
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