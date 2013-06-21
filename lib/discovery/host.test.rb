#!/usr/bin/env ruby

# Add hostmap library folder to path
base = __FILE__
$:.unshift(File.join(File.expand_path(File.dirname(base)), '../../extlib'))
$:.unshift(File.join(File.expand_path(File.dirname(base)), '../../extlib/net-dns/lib'))

require 'test/unit'
require 'discovery/host'

module Hostmap
  module Discovery
    module HostDiscovery
      class HostTest < Test::Unit::TestCase
        def test_to_xml
          host = Host.new('127.0.0.1')
          host.mx << 'a.b.c'
          host.ns << 'c.d.e'
          host.domains << 'f.g.h'
          host.alias << 'i.l.m'
          puts host.to_xml
        end
      end
    end
  end
end