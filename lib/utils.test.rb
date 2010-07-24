#!/usr/bin/env ruby

require 'test/unit'
require 'utils'
require 'exceptions'
require 'constants'

module Hostmap
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
        assert_raise(Hostmap::Exception::EnumerationError) {Utils.sanitize_fqdn("192.168.1.111")}
        assert_raise(Hostmap::Exception::EnumerationError) {Utils.sanitize_fqdn("1.1.1.1")}
        # Strange (caused bugs)
        assert_raise(Hostmap::Exception::EnumerationError) {Utils.sanitize_fqdn("sss dddd sd.co.com")}
        assert_raise(Hostmap::Exception::EnumerationError) {Utils.sanitize_fqdn("sss dddd")}
        # Lenght
        assert_raise(Hostmap::Exception::EnumerationError) {Utils.sanitize_fqdn('s'*120)}
        assert_raise(Hostmap::Exception::EnumerationError) {Utils.sanitize_fqdn('x'*164 + '.com')}
        assert_raise(Hostmap::Exception::EnumerationError) {Utils.sanitize_fqdn('x'*63 + '.com')}
        # Empty
        assert_raise(Hostmap::Exception::EnumerationError) {Utils.sanitize_fqdn("")}
        assert_raise(Hostmap::Exception::EnumerationError) {Utils.sanitize_fqdn(nil)}
      end

      # Tests tld exclusion
      def test_exclude_tld
        assert_equal("a.a", Utils.exclude_tld("a.a.a"))
        assert_equal("a", Utils.exclude_tld("a.a"))
        assert_equal("a.a.a", Utils.exclude_tld("a.a.a.co.uk"))
      end
    end
  end
end
