require 'update-checker/updater'


module HostMap
  module Ui

    #
    # Provides Common Line Interface functionalities.
    #
    class Cli

      def initialize(opts = {})
        # Self reference options for later use
        @opts = opts
      end

      #
      # Runs the CLI.
      #
      def run
        # Check for new releases
        updates = Updates::Checker.new("hostmap").check(HostMap::VERSION)
        if !updates.empty? and @opts['updatecheck']
          puts "WARNING: A new version is available! You can download:"
          updates.each do |file, url|
            puts "\t#{file} at #{url}"
          end
          puts "\n"
        end

        # Run
        begin
          HostMap::Engine.new(@opts).run
        rescue HostMap::Exception::TargetError => ex
          puts "\nError in target value. #{ex.to_s}"
        end
      end
    end

  end
end

