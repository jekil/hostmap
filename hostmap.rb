#!/usr/bin/env ruby

# Add hostmap library folder to path
base = __FILE__
$:.unshift(File.join(File.expand_path(File.dirname(base)), File.join('lib', 'hostmap')))
$:.unshift(File.join(File.expand_path(File.dirname(base)), File.join('lib', 'hostmap-cli')))

require 'console'


puts "hostmap #{Hostmap::VERSION} codename #{Hostmap::CODENAME}"
puts "Coded by Alessandro `jekil` Tanasi <alessandro@tanasi.it>"
puts

# Start hostmap
begin
  Hostmap::Ui::Cli.new(ARGV).run
rescue Interrupt
  puts "\nExecution aborted by user."
rescue SystemExit
  # Do nothing and exit.
rescue Exception => e
  puts "Unhandled exception. Please report this bug sending an email to alessandro@tanasi.it attaching the following text:"
  puts "Message:\n #{e.message}"
  puts "Inspection:\n #{e.inspect}"
  puts "Backtrace of the exception:\n #{e.backtrace.join("\n ")}"
end
