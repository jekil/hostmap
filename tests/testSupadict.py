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
from lib.supadict import *



class testSupadict(unittest.TestCase):
    """
    Tests the supa dupa supa dict
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """

    def setUp(self):
        self.d = supaDict()
        pass
    
    def testNormalUsage(self):
        """
        Normal usage
        """
        
        self.d.antani = "aaa"
        self.assertEqual(self.d.antani, "aaa")
        self.d.antani = "bbb"
        self.assertEqual(self.d.antani, "bbb")
        self.d.gino = "ccc"
        self.assertEqual(self.d.gino, "ccc")
        self.assertEqual(self.d.antani, "bbb")
        
        

if __name__ == '__main__':
    unittest.main()