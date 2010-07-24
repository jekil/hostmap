require 'logger'

module Hostmap

  #
  # Hostmap formatter.
  # Used to print fancy log strings.
  #
  class Formatter < Logger::Formatter

    #
    # Formats message.
    # Provide a call() method that returns the formatted message.
    #
    def call(severity, time, program_name, message)
      datetime = time.strftime("%Y-%m-%d %H:%M")
      print_message = "[#{datetime}] #{String(message)}"
      [ print_message ].join("\n") + "\n"
    end
  end

  #
  # Hostmap logger.
  # Used to have some custom behaviour like extra logging levels and custom formatting.
  #
  class HLogger

    #
    # Iinitialize logging.
    #
    def initialize(opts)
      # Destination.
      $LOG = Logger.new($stdout)
      # Set logging level from preferences.
      if opts['verbose']
        $LOG.level = Logger::DEBUG
      else
        $LOG.level = Logger::INFO
      end
      # Fancy stuff.
      $LOG.datetime_format = "%H:%M:%S"
      $LOG.formatter = Formatter.new
    end
  end
end