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
from lib.core.optionParser import *
from lib.core.hmException import *



class testOptionParser(unittest.TestCase):
    """
    Tests the option parser
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """

    def setUp(self):
        pass
        
    def testNoTarget(self):
        """
        Tests that if no target is specified an exception is raised
        """
        self.assertRaises(hmOptionException, parseArgs)
        
    def testNoArgs(self):
        """
        Tests that if no args the help is printed
        """
        self.assertRaises(hmOptionException, parseArgs)
    
    def testHelp(self):
        """
        Test that help works
        """
        # @todo: implement
        pass
        

if __name__ == '__main__':
    unittest.main()