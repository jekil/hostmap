#!/usr/bin/ruby

require "PlugMan"

#
# Main class to run the Gtk demo.  
# It loads all the plugins then gets the root plugin and extension point and 
# executes all plugins that extend it.
# 
# You may need the libgtk2-ruby libraries installed.  This demo also
# makes use of the df and fortune utilities
#
class GtkDemo

  # load all the plugins
  PlugMan.load_plugins "./demos/gtk_demo_plugins"
  
  # start all plugins
  PlugMan.start_all_plugins()

  #
  # Run all the plugins attached to the :root plugin extension point
  #
  PlugMan.root_extension().each do |plugin|
    plugin.launch()
  end
  
  #
  # The application is finishing, stop the plugins
  #
  PlugMan.stop_all_plugins()
end
