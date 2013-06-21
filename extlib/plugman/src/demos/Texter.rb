#!/usr/bin/ruby

require "PlugMan"
require "getoptlong"

# prints the usage information to the screen.
def print_usage
  puts
  puts "Texter!  Transforms a string using plugins."
  puts
  puts "Usage:\t#{$0} <option>"
  puts "\t-p, --plugin-detail\t# Prints plugin details."
  puts "\t-h, --help\t\t# This screen!"
  puts "\t-i, --input\t\t# A string to transform using plugins."
  puts
  puts "No options is the same as running with -i 'Hello, World!'"
  puts
end

# This programme demonstrates a simple PlugMan application that performs text
# transformations.  It shows both the plugin dependency mechanism as well as the 
# plugin discovery mechanism using extension points.
#
#  Usage:  ./demos/Texter.rb <option>
#        -p, --plugin-detail     # Prints plugin details.
#        -h, --help              # This screen!
#        -i, --input             # A string to transform using plugins.
#
#  No options is the same as running with -i 'Hello, World!'
# 
# Texter explicitly uses the :main plugin and :main defines an extension point 
# :transform.  Any plugins that extend :transform from the :main plugin will be
# invoked by the :main plugin.  
# 
# Go ahead, make your own plugin (perhaps a UPCASE, downcase or squeze plugin.)
# 
# The :case_swap_reverse plugin is invoked via an extension point but makes use 
# of the plugin dependency mechanism. It knows explicitly about :case_swap and
# :reverse plugins and calls them explicilty.
#
class Texter

  # setup the command line options processing.
  opts = GetoptLong.new(
    [ "--plugin-details", "-p", GetoptLong::NO_ARGUMENT ],
    [ "--help", "-h", GetoptLong::NO_ARGUMENT ],
    [ "--input", "-i", GetoptLong::REQUIRED_ARGUMENT]
  )
  
  #
  # load all the plugins in the PLUGIN_DIR
  #
  PlugMan.load_plugins "./demos/text_demo_plugins"
 
  # Start all the pluins
  PlugMan.start_all_plugins
 
  #
  # process the command line options
  #  
  opt_hash = {}
  opts.each do |opt, val|
    opt_hash[opt] = val
  end
  if opt_hash["--plugin-details"]
    # print plugin details
    PlugMan.registered_plugins[:main].plugin_info
  elsif opt_hash["--help"]
    # print help screen
    print_usage
  elsif opt_hash["--input"]
    # execute the transformations using custom input
    PlugMan.registered_plugins[:main].do_xforms(opt_hash["--input"])
  else
    # execute the transformations using Hello, World!
    PlugMan.registered_plugins[:main].do_xforms("Hello, World!")
  end
  
  # stop the plugins
  PlugMan.stop_all_plugins()
end
