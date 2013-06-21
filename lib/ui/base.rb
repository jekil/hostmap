module Hostmap
  
  #
  # Provides user interface support.
  #
  module Ui

    #
    # User interface abstract class to provide a base to develop UI.
    #
    class BaseUi

      #
      # Executes the user interface.
      #
      def run
        raise NotImplementedError
      end

      #
      # Stops the user interface.
      #
      def stop
      end
    end

  end

end