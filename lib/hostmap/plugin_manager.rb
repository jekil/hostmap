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
      def start_all(type, value, callback)
        # Set callback to later user
        @callback = callback

        # Select the right plugin to start
        case type
          when :ip then self.run_ip(value)
        end
        
        # Plugins pool
        @pool = ThreadPool.new(self.engine.opts['threads'].to_i,
                               self.engine.opts['threads'].to_i
                              )
        
        loop do
          @res = []
          until @queue.empty?
            puts @queue.size
            job = @queue.pop
            puts @queue
            key = job.keys[0]
            puts key.info[:name]
            value = job.values[0]
            @pool.process {
              res = start(key, value)
              res.each { |r| self.engine.host_discovery.report(r) }
              sleep 60
            }
          end

          # Time wait
          #unless @pool.spawned == 0 
            #puts "Spawn " + @pool.spawned.to_s
            #puts "Backlog " + @pool.backlog.to_s
          #end

          # Break loop if no more plugins
          #puts @queue.length
          break if @queue.empty? and @pool.spawned == 0
        end
        
        # Stop plugin manager
        #stop_all
      end
      
      def start_once(plugin)
        $LOG.info "Single plugin run mode."
        return start(plugin, self.engine.opts['input'])
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
      
      def start(plugin, input)
        begin
          @res = []
          Timeout::timeout(self.engine.opts['timeout'].to_i) {
            begin
              $LOG.debug "Plugin #{plugin.info[:name]} started with input #{input}"
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
      attr_reader :min, :max, :spawned
    
      def initialize (min, max = nil, &block)
        @min   = min
        @max   = max || min
        @block = block
    
        @cond  = ConditionVariable.new
        @mutex = Mutex.new
    
        @todo    = []
        @workers = []
    
        @spawned       = 0
        @waiting       = 0
        @shutdown      = false
        @trim_requests = 0
        @auto_trim     = false
    
        @mutex.synchronize {
          min.times {
            spawn_thread
          }
        }
      end
    
      def auto_trim?;    @auto_trim;         end
      def auto_trim!;    @auto_trim = true;  end
      def no_auto_trim!; @auto_trim = false; end
    
      def resize (min, max = nil)
        @min = min
        @max = max || min
    
        trim!
      end
    
      def backlog
        @mutex.synchronize {
          @todo.length
        }
      end
    
      def process (*args, &block)
        unless block || @block
          raise ArgumentError, 'you must pass a block'
        end
    
        @mutex.synchronize {
          raise 'unable to add work while shutting down' if @shutdown
    
          @todo << [args, block]
    
          if @waiting == 0 && @spawned < @max
            spawn_thread
          end
    
          @cond.signal
        }
      end
    
      alias << process
    
      def trim (force = false)
        @mutex.synchronize {
          if (force || @waiting > 0) && @spawned - @trim_requests > @min
            @trim_requests -= 1
            @cond.signal
          end
        }
      end
    
      def trim!
        trim true
      end
    
      def shutdown
        @mutex.synchronize {
          @shutdown = true
          @cond.broadcast
        }
    
        @workers.first.join until @workers.empty?
      end
    
    private
      def spawn_thread
        @spawned += 1
    
        thread = Thread.new {
          loop do
            work     = nil
            continue = true
    
            @mutex.synchronize {
              while @todo.empty?
                if @trim_requests > 0
                  @trim_requests -= 1
                  continue = false
    
                  break
                end
    
                if @shutdown
                  continue = false
    
                  break
                end
    
                @waiting += 1
                @cond.wait @mutex
                @waiting -= 1
    
                if @shutdown
                  continue = false
    
                  break
                end
              end
    
              work = @todo.shift if continue
            }
    
            break unless continue
    
            (work.last || @block).call(*work.first)
    
            trim if auto_trim? && @spawned > @min
          end
    
          @mutex.synchronize {
            @spawned -= 1
            @workers.delete thread
          }
        }
    
        @workers << thread
    
        thread
      end
    end
  end
end