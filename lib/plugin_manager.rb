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

        # Plugins pool
		
        #@pool = ThreadPool.new(self.engine.opts['timeout'].to_i, self.engine.opts['threads'].to_i)
        
        Thread.abort_on_exception=true

		#is_ok=true	

        loop do
          @res = []
          until @queue.empty?

		    #while is_ok == false
		    #		sleep 0.1
		    # end

		    #is_ok = false

            job = @queue.pop
            key = job.keys[0]
            value = job.values[0]
            $LOG.debug "Plugin #{key.name.inspect}, #{value}"
            #@pool.process {
            #  begin
				#AAS salva in variabile locale al thread i parametri che gli servono per eseguire correttamente il plugin ( corsa critica sulle variabili key, value , self.engine.opts)

			#	tmp_key = key
			#	tmp_value = value
			#	opts=self.engine.opts
			#	@thread_list << Thread.current
			#	is_ok=true
            #    $LOG.debug "Plugin #{tmp_key.name.inspect} started"
            #    out = tmp_key.run(tmp_value, opts)
			#	puts "#{Thread.current[:key]}"
                # Reports the result
            #    $LOG.debug "Plugin #{key.name.inspect} Output: #{set2txt(out)}"
            #    @res << out
            #  rescue Timeout::Error
            #    @res << key.timeout
            #    $LOG.warn "Plugin #{key.name.inspect} execution expired. Output: #{set2txt(out)}"
            #  rescue Exception
            #    $LOG.debug "Plugin #{key.name.inspect} got a unhandled exception #{$!}"
            #  end
            #}
		
			#AAS manage threads in a simple way
			begin 
			 @thread_list << Thread.new(key,value,self.engine.opts) { |key_thr,value_thr,opts_thr|
					Thread.new (Thread.current) { |main|
						sleep self.engine.opts['timeout'].to_i
              			while main.alive?
							$LOG.info "Plugin #{key_thr.name.inspect} stil alive -> I'm going to kill it"
                			main.raise Timeout::Error
							#AAS Uccide brutalmente il thread
							#@main_thr.kill
                			sleep 0.1
              			end
					}
            		$LOG.debug "Plugin #{key_thr.name.inspect} with target #{value_thr} started in thread"

				 	out = key_thr.run(value_thr, opts_thr)
            		$LOG.info "Plugin #{key_thr.name.inspect} Output: #{set2txt(out)}"
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
				#AAS Uccide brutalmente il thread
				@main.kill
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
