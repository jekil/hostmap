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
from lib.core.controllers.jobController import *
from lib.core.controllers.hmException import *



class testJobController(unittest.TestCase):
    """
    Tests the job controller library
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """

    def setUp(self):
        self.j = jobs()
        pass
    
    def testJobLife(self):
        """
        Test domain Parser
        """
        pass

    def testWrongUse(self):
        """
        Test a bad behaviour
        """
        # Test a bad status
        self.assertRaises(hmParserException, self.j.alter, "antani", "starttting")
        
        
        
if __name__ == '__main__':
    unittest.main()
