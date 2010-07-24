#!/usr/bin/env ruby

# Add hostmap library folder to path
base = __FILE__
$:.unshift(File.join(File.expand_path(File.dirname(base)), 'lib'))
$:.unshift(File.join(File.expand_path(File.dirname(base)), 'extlib/plugman/src'))
$:.unshift(File.join(File.expand_path(File.dirname(base)), 'extlib/net-dns/lib'))

require 'core'
require 'ui/cli/console'
require 'options'


#
# Prints hostmap banner and credits
#
def banner
  puts "hostmap #{Hostmap::VERSION} codename #{Hostmap::CODENAME}"
  puts "Coded by Alessandro `jekil` Tanasi <alessandro@tanasi.it>"
  puts
end

# Load options
options = Hostmap::Options.defaults
options = options.merge(Hostmap::Options.load)
options = options.merge(Hostmap::Options.parse(ARGV))

if ! options['printmaltego']
  # Show banner
  banner
end

if !options['target']
  puts 'No target selected. You must select a target with -t option.'
  exit
end

# Start hostmap
begin
  Hostmap::Ui::Cli.new(options).run
rescue Interrupt
  puts "\nExecution aborted by user."
rescue Exception => e
  puts "Unhandled exception. Please report this bug sending an email to alessandro@tanasi.it attaching the following text:"
  puts "Message:\n #{e.message}"
  puts "Inspection:\n #{e.inspect}"
  puts "Backtrace of the exception:\n #{e.backtrace.join("\n ")}"
end
