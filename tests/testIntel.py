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
from lib.core.discovery.hostIntel import *
from lib.core.hmException import *



class testIntel(unittest.TestCase):
    """
    Tests the host intelligence controller
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """

    def setUp(self):
        self.ip = "127.0.0.1"
        self.intel = Host(self.ip)
        
    def testIp(self):
        self.assertEqual(self.intel.ip, self.ip)    
        
    def testHostname(self):
        host = "abc.antani.com"
        self.intel.hostname = host
        self.assertEqual(self.intel.hostname, host)
        host = "antani.com"
        self.intel.hostname = host
        self.assertEqual(self.intel.hostname, host)

    def testHost(self):
        # Add one
        self.intel.host = "a.a"
        # Add two
        self.intel.setHost("b.a")
        self.assertRaises(hmDupException, self.intel.setHost, "b.a")
        
    def testDomain(self):
        # Add one
        self.intel.domain = "a.a"
        # Add two
        self.intel.setDomain("b.a")
        self.assertRaises(hmDupException, self.intel.setDomain, "b.a")

    def testNameserver(self):
        # Add one
        self.intel.nameserver = "a.a"
        # Add two
        self.intel.setNameserver("b.a")
        self.assertRaises(hmDupException, self.intel.setNameserver, "b.a")

        
        
if __name__ == '__main__':
    unittest.main()