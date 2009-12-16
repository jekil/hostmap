#!/usr/bin/env ruby

require 'test/unit'
require 'utils'

module HostMap
  module Utils
    class UnitTest < Test::Unit::TestCase
  
      # Tests the domain parsing
      def test_parse_domain
        # Usual cases
        assert_equal("b.c", Utils.parse_domain("a.b.c"))
        assert_equal("b.c.d", Utils.parse_domain("a.b.c.d"))
        assert_equal("b.c.d", Utils.parse_domain("aaaaaaaaaaa-=-__.b.c.d"))
        assert_equal("b.c", Utils.parse_domain("b.c"))
        # TLD test
        assert_equal("b.co.uk", Utils.parse_domain("a.b.co.uk"))
        assert_equal("c.co.uk", Utils.parse_domain("c.co.uk"))
        # Bad cases
        assert_raise(RuntimeError) {Utils.parse_domain("a")}
      end
      
      # Tests the domain sanitization
      def test_sanitize_fqdn
        # Usual cases
        assert_equal("a.a.a", Utils.sanitize_fqdn("a.a.a"))
        assert_equal("a.a.a", Utils.sanitize_fqdn("A.a.A"))
        assert_equal("192.168.1.111.aaaa.com", Utils.sanitize_fqdn("192.168.1.111.aaaa.com"))
        # IP
        assert_raise(RuntimeError) {Utils.sanitize_fqdn("192.168.1.111")}
        assert_raise(RuntimeError) {Utils.sanitize_fqdn("1.1.1.1")}
      end
    end
  end
end