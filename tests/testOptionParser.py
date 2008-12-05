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
        # @todo: implement
        pass
    
    def testHelp(self):
        """
        Test that help works
        """
        # @todo: implement
        #argv = sys.argv[:]
        #argv.insert(1, "-h")
        #argv.insert(2, "-t 127.0.0.1")
        #sys.argv = "python hostmap.py -h"
        #parseArgs()
        pass
        

if __name__ == '__main__':
    unittest.main()