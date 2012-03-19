require 'update-checker/updater'


module Hostmap
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
        if @opts['updatecheck']
          puts "Checking for new releases..."
          begin
            updates = Updates::Checker.new("hostmap").check(Hostmap::VERSION)
          rescue Exception
            nil
          end
          if !updates.empty?
            puts "WARNING: A new version is available! You can download:"
            updates.each do |file, url|
              puts "\t#{file} from #{url}"
            end
          else
            puts "No new releases found."
          end
          puts "\n"
        end

        # Run
        begin
          Hostmap::Engine.new(@opts).run
        rescue Hostmap::Exception::TargetError => ex
          puts "\nError in target value. #{ex.to_s}"
        end
      end
    end

  end
end

