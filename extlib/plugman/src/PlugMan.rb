#
# Plugin architecture for ruby applications
# 

# TODO: What happens with cyclic plugin dependencies?
# TODO: Plugin query language to retrieve lists of plugins using metadata criteria

require "logger"
require "observer"
require "find"
include Observable

=begin rdoc

PlugMan is the Plugin Manager for the plugin architecture for ruby applications.

PlugMan is the main interface to the plugin architecture, it manages a register
of plugins and also allows plugins to discover other plugins that attached to 
extension points.

Plugins can:

a. know about eachother explicitly, via the dependency mechanism (e.g. plugin_A knows about plugin_B and requires its services; plugin_A knows about plugin_B at design time and explicitly invokes it.)
b. discover plugins via the extension points mechanism (e.g. plugin_X defines an extension point(s) that other plugins implement (extend), plugin_X only finds out about these at run time and executes them; there may be multiple plugins extending plugin_X's extension point(s) and plugin_X does not need to know about them at design time.)

More information on how this hangs together can be found in the Plugin class'
documentation.

PlugMan defines a convenient "root" plugin that may (or may not) be used as the
base plugin for an application.  It has a single extension point and doesn't
do anything else really.  You are free to ignore the root plugin or make your 
own base plugin if that suits.

If any plugins are defined without a parent plugin, they will be assigned the 
root plugin as a "required" plugin.  This ensures no plugins are orphaned and 
by stopping the root plugin, all other plugins in the system will also be stopped.
(Although it is possible to have no plugins attached to root, so this isn't 
enforced with any vigor...)

The PlugMan.define method is used to register each plugin.  You don't actually 
create classes that extend Plugin, you create a proc that is a parameter to 
PlugMan.define that is used to create an instance of Plugin for you.

Typically all the plugins will live in a subdirectory tree and will be loaded 
early in the application's lifecycle using the PlugMan.load_plugins(PLUGIN_DIR)
method, but plugins can also be loaded at any time in an application's lifecycle.

PlugMan assumes that plugin files have the extension .rb and PlugMan.load_plugins
will attempt to load and register all .rb files in the drectory tree.  Each 
.rb file should have the format
 
  PlugMan.define :plugin_name do
    ... see rdoc for Plugin for more details on how to define a plugin's guts
  end

PlugMan also includes the Observable module.  Listeners can be informed whenever
a plugin is started/stopped.  It is currently a simple mechansim where the name
and new state of the plugin are passed to the listeners.  Currently the states a 
plugin can be in are :stopped, :started or :error.

An example of observer use is:

  # add observer somewhere in your code
  def do_something
    PlugMan.add_observer(self)
  end

  ## the callback method is update
  def update(state, plugin)
    puts "Plugin #{plugin.name.inspect} changed state to #{state.inspect}"
  end

  ## remove observer somewhere
  def do_another_thing
    PlugMan.delete_observer(self)
  end

=end 
module PlugMan

  # Root plugin, any orphan plugins will be automatically belonged to here.
  ROOT_PLUGIN = :root

  # Root extension point, in case you want to use the root plugin and extension
  # point for convenience. Can be safely ignored.
  ROOT_EXTENSION_POINT = :root

  # Version information for PlugMan
  PLUGMAN_VERSION = "0.0.3"

  # PlugMane loggers
  @logger = Logger.new(STDOUT)
  #@logger.level = Logger::DEBUG
  @logger.level = Logger::ERROR
  
  # a hash of the plugins 
  @registered_plugins = {}

    
  #
  # Exceptions related to the plugin framework.
  #
  # Valid types are:
  #   :start_failed     Plugin.start exited badly
  #   :stop_failed      Plugin.stop exited badly
  #   :unknown          For lazy coders!
  #
  class PluginError < RuntimeError

    #The type of error that occurred for the plugin, can be:
    #   :start_failed     Plugin.start exited badly
    #   :stop_failed      Plugin.stop exited badly
    #   :unknown          For lazy coders!
    attr :error_type
  
    # Create a new PluginError specifying the type of error.
    def initialize(type = :unknown)
      @error_type = type
    end
  end

=begin rdoc
A class to hold a plugin's definition.  Objects of this type should only be 
created using PlugMan.define.  
 
In fact, dealing directly with this class 
shouldn't happen much at all and most dealins with the plugin framework
will be through the PlugMan class and the plugins themselves.

Each plugin has the following fields that are useful to programmers using the 
plugin framework in figuring out how plugins interact with eachother:

 * name - plugin name, set automagically by PlugMan.define param, will be a symbol.
 * author - plugin author. 
 * version - plugin version.  Only latest version of a plugin can be active. "1.2.3"
 * extends - extension points this plugin extends { :parent_plug => [:extpt1, :extpt2], parent_plug2 => [:extpt3] }
 * requires - the plugin that contains the extension point this plugin extends
 * extension_points - extension points defined by this plugin [:ext_a:, :ext_b]
 * params - parameters to pass to the parent plugin { :param1 => "abc", :param2 => 123 }
 * state - :started, :stopped, :error 

These can be set using methods magically provided by the PluginMeta module.  e.g. 
to get the author, use (no arguments):

  Plugin.author 

and to set the author, use (single argument):

  Plugin.author "A. Uthor"

An example of how trivial a plugin definition is is shown below, a make-believe 
preferences plugin for a GUI app is being defined (this should be in a file ./plugins/some_subdir/preferences.rb):

  PlugMan.define :preferences do

    # define plugin metadata
    author "Aaron"
    version "1.0.0"
    extends(:menu_bar => [:menu_item], :tool_bar => [:tool_item])
    requires [:widget_factory]
    extension_points [:preference_item, :preferences_open, :preferences_close]
    params(:menu_tree => "View", :menu_text => "Preferences",
      :tool_tip => "Shows the preferences dialog.")

    def do_menu_action
      do_action
    end
  
    def do_tool_action
      do_action
    end
  
    def do_action
      ...
    end
  end

In the above example, the plugin will be discovered by the menu_bar and tool_bar
plugins because this plugin is defined as extending those plugins at their 
extension points.  It should be noted that the plugins being extended define the 
interface for each of those extension points (this is a soft contract and is not
enforced in the plugin architecture.)

This plugin also requires the widget_factory plugin, but it won't be discovered 
by widget_factory in the same manner as the extensions.  A "requires" plugin
is a definite and known plugin that is required for this plugin to perform its
tasks.  In this case, the preferences plugin is relying on a service of the 
widget_factory plugin (presumably for obtaining widgets!)  widget_factory can 
exist happily without the preferences plugin, but preferences will not work if 
widget_factory is not available.

The preferences plugin also defines some extension points that other plugins can
use.  At runtime, the preferences plugin asks PlugMan for all the plugins that
extend its extension points and invokes a contract method on each.  This 
preferences plugin does not know anything about the connected plugins other than
they implement a particular method.  By having this extension point mechanism,
the application can define various specialty preference plugins that suit
particular needs in the system.  e.g. a new product feature, implemented as
plugins, may be an FTP client and this client will make use of the extension 
points defined in the preferences plugin to make use of the applications 
preferences interface.

Parameters can also be passed from a plugin to its parent.  The preferences plugin
tells its parents application information about the plugin (i.e. not plugin metadata)
that may be useful.  Once again this is a soft contract and it is the 
responsibility of the plugin author to document the parameters required for
extensions to define.
=end

  class Plugin

    # The state of the plugin. Values can be :started:, :stopped, :error
    attr_accessor :state 

    # Should not be called directly, use PlugMan.define instead.
    def initialize
    
    end
  
    def initialize
      # give a logger to each plugin
      @logger = Logger.new(STDOUT)
      #@logger.level = Logger::DEBUG
      @logger.level = Logger::ERROR
    end

    #
    # start the plugin. If a plugin needs to perform some specialised startup
    # processing, it should override this method.
    # 
    # :call-seq:
    #   obj.start            -> boolean
    #
    def start
      true
    end

    #
    # stop the plugin. If a plugin needs to perform some specialised stop
    # processing, it should override this method.
    # 
    # :call-seq:
    #   obj.stop            -> boolean
    #
    def stop
      true
    end
  
    #
    #The base dir name that the plugin was loaded from
    #
    def dirname
      File.dirname source_file
    end
 
    #
    # Allow plugins to specify metadata fields w/ magic
    #
    def self.define_meta_field(*fields)
      class_eval do
        fields.each do |field_name|
          define_method(field_name) do |*varg|
            if varg.size == 0
              instance_variable_get("@#{field_name}")
            else 
              instance_variable_set("@#{field_name}", *varg)
            end
          end
        end
      end
    end
  
    # 
    # Metadata for the plugin, this helps the plugin system wire up the plugins
    # 
    define_meta_field :name,      # plugin name, set automagically from PlugMan.define param.
    :author,                      # plugin author. 
    :version,                     # plugin version.  Only latest version of a plugin can be active.
    :extends,                     # extension points this plugin extends { :parent_plug => [:extpt1, :extpt2], parent_plug2 => [:extpt3] }
    :requires,                    # the plugins that are required by this plugin (not needed for extensions though)
    :extension_points,            # extension points defined by this plugin [:ext_a:, :ext_b]
    :params,                      # parameters to pass to the parent plugin { :param1 => "abc", :param2 => 123 }
    :source_file,                 # the file that the plugin was loaded from, populated by PlugMan.
    :state                        # :started, :stopped, :error
  
    # Gets a hash of all the registered plugins, key is a plugin name (as 
    # a symbol), value is the Plugin object.
    def PlugMan.registered_plugins
      @registered_plugins
    end
  
    # Gets the plugins attached to the root plugin and extension point.
    # 
    # :call-seq:
    #   PlugMan.root_extension        -> [plug_a, plug_n]
    #
    def PlugMan.root_extension
      extensions(ROOT_PLUGIN, ROOT_EXTENSION_POINT)
    end
  
    # Given a plugin and extension point names, returns all the plugins that use that
    # extension point.
    # 
    # :call-seq:
    #    PlugMan.extensions(parent_plugin_name, ext_point)    -> [plug_1, plug_n]
    #
    def PlugMan.extensions(parent_plugin_name, ext_point)

      @logger.debug { "Get extensions for " << parent_plugin_name.to_s << ":" << ext_point.to_s }
      # loop all the plugins in the system, weeding out the ones that are
      # not connected to the given plugin and extension point
      ret = []
      @registered_plugins.each do |nm, ob|
        if ob.extends && ob.state == :started
          ob.extends.each do |nm2, ob2|
            if nm2.to_sym == parent_plugin_name.to_sym && ob2.include?(ext_point.to_sym)
              ret.push ob
            end
          end
        end
      end
      ret
    end

    #
    # Registers a plugin.  See Plugin for more information about defining a plugin.
    # 
    # Do not create plugins using Plugin.new as they won't be registered with
    # PlugMan.
    # 
    # The plug_name must be unique amongst plugins and it will be 
    # converted to a symbol.  &block is the actual code that will 
    # make up the plugin (once again, see Plugin for more details.)  
    # 
    # Once a plugin is defined, it will be available using PlugMan.registered_plugins[:plug_name]
    # and any plugins that extend it can be discovered using PlugMan.extensions(:plug_name, ext_point)
    # 
    # If a plugin is declared more than once, the instance with the greatest version
    # number will be used (any older version will be discarded.)
    # 
    # When a plugin is initially defined, it is put into the :stopped state.
    #
    def PlugMan.define(plug_name, &block)

      # create plugin object and execute the metadata block
      p = PlugMan::Plugin.new
    
      # set some plugin metadata
      p.name plug_name.to_sym
      p.source_file @load_path

      p.instance_eval(&block)

      # check for existing plugin with this name
      exist = @registered_plugins[plug_name.to_sym]
      if exist && exist.version > p.version
        @logger.warn { "Plugin #{plug_name.inspect} already exists with newer version of #{exist.version.to_s} (attempted to register version #{p.version.to_s}.)" }
      else
        if exist && p.version >= exist.version
          @logger.warn { "Plugin #{plug_name.inspect} already exists with older version of #{exist.version.to_s}, replacing with version #{p.version.to_s}." }      
        end
        @registered_plugins[plug_name.to_sym] = p
      end

      # set state to stopped (plugins must be started explicitly)
      p.state :stopped
      p.extension_points [] unless p.extension_points
      if !p.requires || p.requires.empty? && (!p.extends || p.extends.keys.empty?)
        p.requires [:root] unless p.name == ROOT_PLUGIN
      end

      @logger.debug { "Created plugin #{plug_name.inspect}" + (p.extension_points.empty? ? "." : ", extension points: " + p.extension_points.join(", ")) }
    end

    #
    # Gets all the plugins that a plugin requires (a combination of :requires and :extends plugins)
    # 
    # :call-seq:
    #    PlugMan.depends_on(plugin_name)    -> [plug_1, plug_n]
    #
    def PlugMan.depends_on(plugin_name)
      plugin = @registered_plugins[plugin_name]
      ret = []
      ret += plugin.requires
      ret += plugin.extends.keys if plugin.extends
      ret.uniq
    end
  
    #
    # Gets all the plugins that depend on the named plugin (the plugins that decare plugin_name as :required or :extends)
    # 
    # :call-seq:
    #    PlugMan.required_by(plugin_name)    -> [plug_1, plug_n]
    #
    def PlugMan.required_by(plugin_name)
      ret = []
      # iterate all the plugins that declare this plugin as required
      @registered_plugins.each do |nm, ob|
        ret << nm if ob.requires.include?(plugin_name)  || (ob.extends && ob.extends.keys.include?(plugin_name))
      end
      ret.uniq
    end
    
    # 
    # Starts all plugins that are registered.
    # 
    def PlugMan.start_all_plugins
      @logger.debug { "Starting all plugins" }
      @registered_plugins.keys.each do |name|
        begin
          start_plugin(name)
        rescue PluginError => err
          @logger.error { "Error starting plugin #{name.inspect}, reason #{err.error_type}" }
        end
      end
    end

    # 
    # Stops all plugins that are registered.
    # 
    def PlugMan.stop_all_plugins
      @logger.debug { "Stopping all plugins" }
      @registered_plugins.keys.each do |name|
        begin
          stop_plugin(name)
        rescue PluginError => err
          @logger.error { "Error stopping plugin #{name.inspect}, reason #{err.error_type}" }
        end
      end
    end
  
    #
    # Starts a plugin and the plugins it requires.  When a plugin is started, 
    # any observers are notified of the change.
    #
    # If a plugin isn't started correctly, a PluginError(:start_failed) exception
    # is raised.
    #
    def PlugMan.start_plugin(name)
      plug = @registered_plugins[name]
    
      depends_on(name).each do |rqdname|
        rqd = @registered_plugins[rqdname]
        if !rqd
          @logger.error { "Invalid plugin dependency #{rqdname.inspect} for plugin #{name.inspect}" }
        end
        if rqd.state == :stopped || rqd.state == :error
          start_plugin(rqdname)
        end
      end
	
      # Now that all the required plugins are started, start this plugin
      if plug.state == :stopped || plug.state == :error
        @logger.debug { "Starting plugin #{plug.name.inspect}" }
        if plug.start
          plug.state :started
          changed
          notify_observers(:started, plug)
        else
          plug.state :error
          @logger.error { "Failed to start plugin #{name.inspect}" }
          changed
          notify_observers(:error, plug)

          raise PluginError.new(:start_failed)
        end
      end
    end
  
    #
    # Stops a plugin and the plugins that depend on it. When a plugin is stopped, 
    # any observers are notified of the change.
    # 
    # If a plugin isn't stopped correctly, a PluginError(:stop_failed) exception
    # is raised.
    #
    def PlugMan.stop_plugin(name)
      plug = @registered_plugins[name]

      required_by(name).each do |nm|
        stop_plugin(nm)
      end
    
      if plug && plug.state == :started || plug.state == :error
        @logger.debug { "Stopping plugin #{plug.name.inspect}" }

        if plug.stop
          plug.state :stopped
          changed
          notify_observers(:stopped, plug)
        else
          plug.state :error
          @logger.error { "Failed to stop plugin #{name.inspect}" }
          changed
          notify_observers(:error, plug)
          raise PluginError.new(:stop_failed)
        end
      end
    end


    #
    # Load all the plugins in plugin_dir
    #
    def PlugMan.load_plugins(plugin_dir)
      Find.find(plugin_dir) do |path|
        if path =~ /\.rb$/
          @load_path = path # nasty, nasty, nasty.  Need a better way to pass a plugin's load path to it.
          load path
        end
      end
    end


    # 
    # Define the root plugin, the base plugin for an application 
    # should extend from here (e.g. your :core or :main type plugin)
    # or declare the root plugin as a requires value.
    # 
    PlugMan.define PlugMan::ROOT_PLUGIN do
      author "System"
      version "0.0.0"
      extends
      requires []
      extension_points [PlugMan::ROOT_EXTENSION_POINT]
      state :started
    end
  end
end
