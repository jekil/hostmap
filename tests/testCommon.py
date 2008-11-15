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
from lib.core.controllers.hmException import *



class testCommon(unittest.TestCase):
    """
    Tests the common functions library
    @license: Private licensing
    @author: Alessandro Tanasi
    """

    def setUp(self):
        pass
    
    def testOk(self):
        """
        Normal and not malformed hostnames
        """
        self.assertEqual(parseDomain("a.b.c"), "b.c")
        self.assertEqual(parseDomain("a.b.c.d"), "b.c.d")
        self.assertEqual(parseDomain("aaaaaaaaaaa-=-__.b.c.d"), "b.c.d")
        
    def testStrange(self):
        """
        Strange conditions
        """
        self.assertEqual(parseDomain("b.c"), "b.c")
        self.assertRaises(hmParserException, parseDomain, "c")
        
        
if __name__ == '__main__':
    unittest.main()
