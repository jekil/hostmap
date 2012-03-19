require 'timeout'

module Hostmap

  #
  # Discovery plugins used by hostmap.
  #
  module Plugins

    #
    # Base plugin interface.
    #
    class BasePlugin
      def initialize
        @res = Set.new
      end
      
      #
      # Gets plugin infos.
      #
      def info
        raise NotImplementedError
      end

      # 
      # Execute plugin.
      #
      def execute(arg, opts)
        raise NotImplementedError
      end

      #
      # Action called when plugin timeouts.
      #
      def timeout
        return @res
      end
    end

    class PluginContainer
      def initialize(path=nil)
        @path = path
        @args = nil
        @plugin = nil
        # Autoload if path is supplied
        self.load(@path) if @path
      end

      def load(path)
        $LOG.plugin "Parsing plugin: #{path}"
        #begin
          require path
        #rescue
        #  nil #TODO:
        #  puts 'aaa'
        #end
      end

      def run
        Timeout.new(1) do
          @plugin.execute(@args)
        end
      end

      attr_reader :path
      attr_reader :plugin
    end

    class PluginLoader
      def initialize(path=Hostmap::PLUGINDIR)
        @base_path = path
        @paths = []
      end

      #
      # Search for plugins from plugin directory
      #
      def search
        $LOG.debug "Searching for plugins."
        Dir.glob("#{@base_path}/**/*.rb").each do |f|
          @paths << f
        end
      end

      attr_reader :paths

#      def load
#          require f
#          if defined?(HostmapPlugin)
#            $LOG.plugin "Parsing plugin: #{f}"
#            @loaded_plugins[f] = HostmapPlugin
#            Object.send(:remove_const, :HostmapPlugin)
#          end
#        end
#        $LOG.plugin "Loaded #{plugins_by_ip.size + plugins_by_ns.size + plugins_by_domain.size + plugins_by_hostname.size} plugins"
#        $LOG.plugin "Loaded #{plugins_by_ip.size} plugins depending from ip"
#        $LOG.plugin "Loaded #{plugins_by_domain.size} plugins depending from domain"
#        $LOG.plugin "Loaded #{plugins_by_ns.size} plugins depending from name server"
#        $LOG.plugin "Loaded #{plugins_by_hostname.size} plugins depending from hostname"
#      end
    end
  end
end
