#!/usr/bin/ruby1.9.1

# Add hostmap library folder to path
base = __FILE__
$:.unshift(File.join(File.expand_path(File.dirname(base)), 'lib'))
$:.unshift(File.join(File.expand_path(File.dirname(base)), 'extlib/plugman/src'))
$:.unshift(File.join(File.expand_path(File.dirname(base)), 'extlib/libxml/lib'))
$:.unshift(File.join(File.expand_path(File.dirname(base)), 'extlib/net-dns/lib'))

require 'libxml'
include LibXML

require 'constants'
include Hostmap

require 'PlugMan'

require 'thread'

require 'set'

require 'find'

require 'optparse'


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

def print_plugins_list ()
	puts "List of plugins:"
	index=1
	$plugins_list.each do |plugin|
		puts "\t#{index}.\t#{plugin}"
		index = index + 1
	end		
	exit 1
end


$plugins_list=[]
Find.find(PLUGINDIR+"/web") do |path|
	if path =~ /\.rb$/
		$plugins_list << path.split("/")[path.split("/").size-1].split(".")[0] 
    end
end

options = {}
opts = OptionParser.new do |opts|
	opts.banner = "Usage: #$0 -p ALL|<plugin>"
	options[:plugin_spec]= ""
	opts.on("-p [STRING]", "--plugin [STRING]", "set target plugin: ALL for all web plugins") do |t|
		options[:plugin_spec] = t
	end
end.parse!

if options.size==0 || options[:plugin_spec].size==0
	puts "Usage: #$0 -p ALL|<plugin>"
	print_plugins_list
end

if options[:plugin_spec] != "ALL"
	found=false
	$plugins_list.each do |plugin|
		if plugin == options[:plugin_spec]
			found = true
		end 
	end	

	if !found
		puts "ERROR: plugin #{options[:plugin_spec]} does not exist"
		print_plugins_list
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

if options[:plugin_spec] == "ALL"
	PlugMan.start_all_plugins
else
	PlugMan.start_plugin(options[:plugin_spec].to_sym)
end

puts "\nTesting hostmap plugins .... this operation could take a while"
puts "\n"

dnsResolver = Net::DNS::Resolver.new
dnsResolver.log_level = Net::DNS::UNKNOWN

plugin_types.each do |type|

	PlugMan.extensions(:main, type.to_sym).each do |plugin|

		plugins.each do |testplugin|

			if plugin.name.inspect == testplugin.name

				#puts "Testing plugin #{testplugin.name}"

				tests_number=1
				addresses=[]
				
				if type == "ip"
					number=0
					dnsResolver.query(testplugin.parm_value, Net::DNS::A).answer.each do |rr|
						#puts rr.class
						if rr.class == Net::DNS::RR::A
							addresses << rr.address.to_s
						end
					end

					testplugin.parm_value=addresses.shift

					tests_number=addresses.size	

					if tests_number <= 0 
						puts "DNS query fails for plugin #{plugin.name.inspect}"
					end
				end

				res=plugin.run(testplugin.parm_value,testplugin.opts)
				
				if  res.size > 0
					if res.entries[0][testplugin.results_var.to_sym][testplugin.regexp].size > 0

						puts "\033[32mPlugin \t#{plugin.name.inspect}\t=>\tOK\033[0m"
					else
						puts "\033[31mPlugin \t#{plugin.name.inspect}\t=>\tKO : Not compatible results\033[0m"
					end
				else

						is_ok=false
						if type=="ip"	
							addresses.each do |address|
								res=plugin.run(address,testplugin.opts)
								if res.size > 0
									if res.entries[0][testplugin.results_var.to_sym][testplugin.regexp].size > 0
										puts "\033[32mPlugin \t#{plugin.name.inspect}\t=>\tOK\033[0m"
									else
										puts "\033[31mPlugin \t#{plugin.name.inspect}\t=>\tKO : Not compatible results\033[0m"
									end
									is_ok=true
									break
								end
							end
						end
						if ! is_ok
							puts "\033[31mPlugin \t#{plugin.name.inspect}\t=>\tKO : No results found\033[0m"	
						end
				end

			end

		end

	end

end
	
puts ""
PlugMan.stop_all_plugins
