require 'msf/core'


class Metasploit3 < Msf::Auxiliary

	include Msf::Auxiliary::Report

	def initialize(info = {})
		super(update_info(info,	
			'Name'			=> 'HOSTMAP Virtual Host Discovery Module',
			'Description'	=> %q{
				hostmap is a free, automatic, hostnames and virtual hosts discovery tool. It's goal is to enumerate 
				all hostnames and configured virtual hosts on an IP address. The primary users of hostmap are professionals 
				performing vulnerability assessments and penetration tests.
			},
			'Author'		=> [ 'Alessandro Tanasi <alessandro[at]tanasi.it>' ],
			'License'		=> MSF_LICENSE,
			'Version'		=> '$Revision$',
			'References'	=>
				[
					['URL', 'http://hostmap.lonerunners.net'],
				]
			))
		
		register_options(
			[
				OptString.new('TARGET', [ true,  "Target IP address", '' ]),
				OptString.new('OPTS', [ false,  "The hostmap options to use", ''  ]),
				OptPath.new('HOSTMAP_PATH', [ true,  "The hostmap >= 0.2.1 full path ", '/hostmap/hostmap.rb' ]), 
			], self.class)
		register_advanced_options(
			[
				OptBool.new('BRUTE_FORCING', [ true,  "Enables DNS names brute forcing", true ]),
			], self.class)
	end
	
	def run
	  hostmap = datastore['HOSTMAP_PATH'] 
			
		if not hostmap
		  print_error("The hostmap script could not be found.")
			return
		end
		
		cmd  = hostmap + ' ' + datastore['OPTS'] + ' -t '  + datastore['TARGET']
		cmd << ' --without-bruteforce' if not datastore['BRUTE_FORCING'] 
		
		print_status("exec: #{cmd}")
		IO.popen(cmd) do |io|
			io.each_line do |line|
				print_line("HOSTMAP: " + line.strip)
			end
		end
	end

end
