#!/usr/bin/ruby1.9.1

# Add hostmap library folder to path
base = __FILE__
$:.unshift(File.join(File.expand_path(File.dirname(base)), 'lib'))
$:.unshift(File.join(File.expand_path(File.dirname(base)), 'extlib/plugman/src'))
$:.unshift(File.join(File.expand_path(File.dirname(base)), 'extlib/libxml/lib'))

require 'libxml'
include LibXML

require 'constants'
include Hostmap

require 'PlugMan'

require 'thread'

require 'set'


class TestPlugin

	attr_accessor :description
	attr_accessor :name
	attr_accessor :type
	attr_accessor :parm_value
	attr_accessor :opts
	attr_accessor :results_var
	attr_accessor :regexp

	def initialize
		@description = ""
		@name = ""
		@type = ""
		@parm_value = ""
		@opts = {}
		@results_var= ""
		@regexp=/(.*)?/
	end
end 

dtd = XML::Dtd.new(File.read("#{ENV['PWD']}/test/conf/test.dtd"))

doc = XML::Document.file("#{ENV['PWD']}/test/conf/test.xml")

begin

	doc.validate(dtd)

rescue Exception => e
	puts "#{e.inspect}"
	exit 1

end

found = true
index = 1
plugins = []
plugin_types = []

while found
	
	found = false

	if doc.find("//HostmapTests/source[#{index}]").first != nil		

		plug = TestPlugin.new

		found = true

		plug.description=doc.find("/HostmapTests/source[#{index}]/description/@value").first.value	

		plug.name=doc.find("/HostmapTests/source[#{index}]/plugin/@name").first.value	

		plug.type=doc.find("/HostmapTests/source[#{index}]/plugin/@type").first.value	
		plugin_types << plug.type


		plug.parm_value=doc.find("/HostmapTests/source[#{index}]/parameter/@value").first.value	

		plug.results_var=doc.find("/HostmapTests/source[#{index}]/result/@var").first.value	

		regexp = doc.find("/HostmapTest/source[#{index}]/result/@regexp").first

		if regexp.class != NilClass
			plug.regexp=/#{regexp.value}/
		end

		opts={}

		if doc.find("/HostmapTests/source[#{index}]/arroptions").first != nil
			l_index = 1

			while l_index <= doc.find("/HostmapTests/source[#{index}]/arroptions/@length").first.value.to_i
				
				opt_name = doc.find("/HostmapTests/source[#{index}]/arroptions/option[#{l_index}]/@name").first.value		

				opt_value = doc.find("/HostmapTests/source[#{index}]/arroptions/option[#{l_index}]/@value").first.value

				opts[opt_name] = opt_value 
				#puts "Found option #{opt_name}=#{opt_value}"

				l_index += 1

			end
		end

		plug.opts = opts	
		
		plugins << plug
    end

	index = index + 1	

end

plugin_types = plugin_types.uniq

#plugins.each do |plugin|
#	puts "Found plugin #{plugin.name}"
#end

#loading all plugins
PlugMan.load_plugins PLUGINDIR  

#starting only plugins configured for test
#PlugMan.start_plugin(:main)

PlugMan.start_all_plugins

puts "\nTesting hostmap plugins .... this operation could take a while"
puts "\n"

plugin_types.each do |type|

	PlugMan.extensions(:main, type.to_sym).each do |plugin|

		plugins.each do |testplugin|

			if plugin.name.inspect == testplugin.name

				#puts "Testing plugin #{testplugin.name}"

				res=plugin.run(testplugin.parm_value,testplugin.opts)
				
				if  res.size > 0
					if res.entries[0][testplugin.results_var.to_sym][testplugin.regexp].size > 0

						puts "\033[32mPlugin \t#{plugin.name.inspect}\t=>\tOK\033[0m"
					else
						
						puts "\033[31mPlugin \t#{plugin.name.inspect}\t=>\tKO : Not compatible results\033[0m"

					end
				else

					puts "\033[31mPlugin \t#{plugin.name.inspect}\t=>\tKO : No results found\033[0m"	

				end

			end

		end

	end

end
	
PlugMan.stop_all_plugins
