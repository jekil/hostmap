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
        begin
          HostMap::Engine.new(@opts).run
        rescue HostMap::Exception::TargetError => ex
          puts "\nError in target value. #{ex.to_s}"
        end
      end
    end

  end
end

