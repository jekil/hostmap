#!/usr/bin/env python
#
#   hostmap
#
#   Author:
#    Alessandro `jekil` Tanasi <alessandro@tanasi.it>
#
#   License:
#
#    This file is part of hostmap.
#
#    hostmap is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    hostmap is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with hostmap.  If not, see <http://www.gnu.org/licenses/>.



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
        if (argstr == "xml"):
            runner = xmlrunner.XMLTestRunner(sys.stdout)

    runner.run(suite)
