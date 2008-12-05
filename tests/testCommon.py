#!/usr/bin/env python
#
#   hostmap
#
#   Author:
#    Alessandro `jekil` Tanasi <alessandro@tanasi.it>
#
#   License:
#    This program is private software; you can't redistribute it and/or modify
#    it. All copies, included printed copies, are unauthorized.
#    
#    If you need a copy of this software you must ask for it writing an
#    email to Alessandro `jekil` Tanasi <alessandro@tanasi.it>


import sys
sys.path.append("../")

import unittest
from lib.common import *
from lib.core.hmException import *



class testCommon(unittest.TestCase):
    """
    Tests the common functions library
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """

    def setUp(self):
        pass
    
    def testParseDomain(self):
        """
        Test domain Parser
        """
        # Normal use
        self.assertEqual(parseDomain("a.b.c"), "b.c")
        self.assertEqual(parseDomain("a.b.c.d"), "b.c.d")
        self.assertEqual(parseDomain("aaaaaaaaaaa-=-__.b.c.d"), "b.c.d")
        # Strange use
        self.assertEqual(parseDomain("b.c"), "b.c")
        self.assertRaises(hmParserException, parseDomain, "c")
        
    def testSanitizeFqnd(self):
        """
        Test fqdn sanitization
        """
        self.assertEqual(sanitizeFqdn("a.a.a"), "a.a.a")
        self.assertEqual(sanitizeFqdn("A.a.A"), "a.a.a")
        
        
        
if __name__ == '__main__':
    unittest.main()
