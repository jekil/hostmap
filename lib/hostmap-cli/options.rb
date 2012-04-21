require 'optparse'
require 'yaml'
require 'exceptions'


module Hostmap

  #
  # Provides options handling, loading and command line options parsing.
  #
  class Options

    #
    # Return a hash describing the options.
    #
    def self.parse(args)
      # Add defaults and config file options
      options = defaults
      options = options.merge(load)

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #$0 [options] -t [target]"

        opts.separator ""
        opts.separator "Target options:"

        opts.on("-t [STRING]", "--target [STRING]", "set target domain") do |t|
          options['target'] = t
        end

        opts.separator ""
        opts.separator "Plugin options:"

        opts.on("-l", "--list-plugins", "lists available plugin") do
          options['list'] = true
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

        opts.on("", "--timeout [STRING]", "set plugin timeout") do |t|
          options['timeout'] = t
        end

        opts.on("", "--threads [STRING]", "set concurrent threads number") do |t|
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

        opts.on("", "--with-update", "checks for updates") do
          options['updatecheck'] = true
        end

      end

      opts.parse!(args)
      puts options.inspect
      
      # Check arguments
      self.check(options)

      return options
    end

    private

    #
    # Checks options coerence due to hostmap logic.
    #
    def self.check(args)
      if args.length == 0
        raise Hostmap::Exception::OptionError, "Please provide a valid option. Use -h to print available options."
      end
      if !(args['target'] or args['list'])
        raise Hostmap::Exception::OptionError, 'No target selected. You must select a target with -t option.'
      end
      if args['target'] and args['list']
        raise Hostmap::Exception::OptionError, 'You cannot use -t and -l options together.'
      end
    end

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
      options['updatecheck'] = false
      return options
    end

  end
end