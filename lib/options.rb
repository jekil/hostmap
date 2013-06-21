require 'optparse'
require 'yaml'


module Hostmap

  #
  # Provides options handling, loading and command line options parsing.
  #
  class Options

    #
    # Load options from configuration file
    #
    def self.load
      return YAML.load_file(Hostmap::CONFFILE)
    end

    #
    # Defaults options
    #
    def self.defaults
      options = {}
      options['dnszonetransfer'] = false
      options['dnsbruteforce'] = true
      options['dnsexpansion'] = true
      options['dnsbruteforcelevel'] = 'lite'
      options['paranoid'] = true
      options['timeout'] = 600
      options['threads'] = 5
      return options
    end

    #
    # Return a hash describing the options.
    #
    def self.parse(args)
      options = {}

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #$0 [options] -t [target]"

        opts.separator ""
        opts.separator "Target options:"

        opts.on("-t [STRING]", "--target [STRING]", "set target domain") do |t|
          options['target'] = t
        end

        opts.separator ""
        opts.separator "Discovery options:"

        opts.on("", "--with-zonetransfer", "enable DNS zone transfer check") do
          options['dnszonetransfer'] = true
        end

        opts.on("", "--without-bruteforce", "disable DNS bruteforcing") do
          options['dnsbruteforce'] = false
        end
        
        opts.on("", "--without-dnsexpansion", "disable DNS TLD expansion") do
          options['dnsexpansion'] = false
        end

        opts.on("", "--bruteforce-level [STRING]", "set bruteforce aggressivity, values are lite, custom or full (default is lite)") do |t|
          options['dnsbruteforcelevel'] = t
        end

        opts.on("", "--without-be-paranoid", "don't check the results consistency") do
          options['paranoid'] = false
        end

        opts.on("", "--http-ports [STRING]", "set a comma separated list of custom HTTP ports to check") do |t|
          options['httpports'] = t
        end

        opts.on("", "--only-passive", "passive discovery, don't make network activity to the target network") do
          options['onlypassive'] = true
        end

        opts.on('', "--timeout [STRING]", "set plugin timeout") do |t|
          options['timeout'] = t
        end

        opts.on('', "--threads [STRING]", "set concurrent threads number") do |t|
          options['threads'] = t
        end

        opts.separator ""
        opts.separator "Networking options:"

        opts.on("-d [STRING]", "--dns [STRING]", "set a comma separated list of DNS servers IP addresses to use instead of system defaults") do |t|
          options['dns'] = t
        end

        opts.separator ""
        opts.separator "Output options:"

        opts.on("", "--print-maltego", "set output formatted for Maltego") do
          options['printmaltego'] = true
        end

        opts.on("-v", "--verbose", "set verbose mode") do
          options['verbose'] = true
        end

        opts.on_tail("-h", "--help", "show this help message") do
          puts opts
          exit
        end

        opts.separator ""
        opts.separator "Misc options:"

        opts.on("", "--without-update", "skip update check") do
          options['updatecheck'] = false
        end
      end

      opts.parse!(args)

      options
    end
  end
end