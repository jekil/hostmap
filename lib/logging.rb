require 'logger'

module Hostmap

  #
  # hostmap custom pretty logger.
  #
  class MyLogger < Logger::Formatter

    #
    # Provide a call() method that returns the formatted message.
    #
    def call(severity, time, program_name, message)
      datetime = time.strftime("%Y-%m-%d %H:%M")
      print_message = "[#{datetime}] #{String(message)}"
      [ print_message ].join("\n") + "\n"
    end
  end

  #
  # hostmap global logger
  #
  class HMLogger

    #
    # Iinitialize logging
    #
    def initialize(opts)
      $LOG = Logger.new($stdout)
      # Set logging level
      if opts['verbose']
        $LOG.level = Logger::DEBUG
      else
        $LOG.level = Logger::INFO
      end
      $LOG.datetime_format = "%H:%M:%S"
      $LOG.formatter = MyLogger.new
    end
  end
end