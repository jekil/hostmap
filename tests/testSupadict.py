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