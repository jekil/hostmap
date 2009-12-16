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
        HostMap::Engine.new(@opts).run
      end
    end

  end
end

