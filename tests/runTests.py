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
import xmlrunner
sys.path.append("../")

import unittest

# Importing tests
from testCommon import *
from testOptionParser import *
from testIntel import *
from testSupadict import *
from testJobController import *
from testConfiguration import *



if __name__ == '__main__':
    suite = unittest.TestSuite()

    suite.addTest(unittest.makeSuite(testCommon))
    suite.addTest(unittest.makeSuite(testOptionParser))
    suite.addTest(unittest.makeSuite(testIntel))
    suite.addTest(unittest.makeSuite(testSupadict))
    suite.addTest(unittest.makeSuite(testJobController))
    suite.addTest(unittest.makeSuite(testConfiguration))
    
    runner = unittest.TextTestRunner(verbosity=4)

    for argstr in sys.argv:
        #if (argstr == "html"):
        #    runner = HTMLTestRunner.HTMLTestRunner(verbosity=0)
        if (argstr == "xml"):
            runner = xmlrunner.XMLTestRunner(sys.stdout)

    runner.run(suite)
