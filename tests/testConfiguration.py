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
sys.path.append("../")

import unittest
from lib.core.configuration import *



class testConfiguration(unittest.TestCase):
    """
    Tests the configuration
    @license: GNU Public License version 3
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