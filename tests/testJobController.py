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
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.


import sys
sys.path.append("../")

import unittest
from lib.core.controllers.jobController import *
from lib.core.hmException import *



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
    
    def testLifeDone(self):
        """
        Test a good plugin life
        """
        self.j.alter("a", "starting")
        self.assertEqual(self.j.check(), False)
        self.j.alter("a", "waiting")
        self.assertEqual(self.j.check(), False)
        self.j.alter("a", "done")
        self.assertEqual(self.j.check(), True)
    
    def testLifeFailed(self):
        """
        Test a failed plugin life
        """
        self.j.alter("a", "starting")
        self.assertEqual(self.j.check(), False)
        self.j.alter("a", "waiting")
        self.assertEqual(self.j.check(), False)
        self.j.alter("a", "failure")
        self.assertEqual(self.j.check(), True)
        
    def testCombinedLife(self):
        """
        Test a multi plugin life
        """
        self.j.alter("a", "starting")
        self.assertEqual(self.j.check(), False)
        self.j.alter("a", "waiting")
        self.assertEqual(self.j.check(), False)
        self.j.alter("b", "starting")
        self.assertEqual(self.j.check(), False)
        self.j.alter("a", "failure")
        self.assertEqual(self.j.check(), False)
        self.j.alter("b", "waiting")
        self.assertEqual(self.j.check(), False)
        self.j.alter("b", "done")
        self.assertEqual(self.j.check(), True)

    def testWrongUse(self):
        """
        Test a bad behaviour
        """
        # Test a bad status
        self.assertRaises(hmParserException, self.j.alter, "antani", "starttting")
        
        
        
if __name__ == '__main__':
    unittest.main()
