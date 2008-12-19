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
from lib.core.configuration import *



class testConfiguration(unittest.TestCase):
    """
    Tests the configuration
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """

    def setUp(self):
        self.c = Configuration()
        pass
    
    def testGetNotFoundKey(self):
        """
        Get a non found key
        """
        
        self.assertEqual(self.c.antani, None)
        
        

if __name__ == '__main__':
    unittest.main()