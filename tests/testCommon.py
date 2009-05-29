#!/usr/bin/env python
"""
hostmap

Author:
Alessandro `jekil` Tanasi <alessandro@tanasi.it>

License:

This file is part of hostmap.

hostmap is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

hostmap is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with hostmap.  If not, see <http://www.gnu.org/licenses/>.
"""


import sys
sys.path.append("../")

import unittest
from lib.common import *
from lib.core.hmException import hmParserException, hmResultException



class testCommon(unittest.TestCase):
    """
    Tests the common functions library
    @license: GNU Public License version 3
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """

    def setUp(self):
        pass
    
    def testParseDomain(self):
        """
        Test domain Parser
        """
        # Normal use
        self.assertEqual(parseDomain("a.b.c"), "b.c")
        self.assertEqual(parseDomain("a.b.c.d"), "b.c.d")
        self.assertEqual(parseDomain("aaaaaaaaaaa-=-__.b.c.d"), "b.c.d")
        # Strange use
        self.assertEqual(parseDomain("b.c"), "b.c")
        self.assertRaises(hmParserException, parseDomain, "c")
        
    def testSanitizeFqnd(self):
        """
        Test fqdn sanitization
        """
        self.assertEqual(sanitizeFqdn("a.a.a"), "a.a.a")
        self.assertEqual(sanitizeFqdn("A.a.A"), "a.a.a")
        self.assertRaises(hmResultException, sanitizeFqdn, "1.1.1.1")
        self.assertRaises(hmResultException, sanitizeFqdn, "192.168.1.111")
        self.assertEqual(sanitizeFqdn("192.168.1.111.aaaa.com"), "192.168.1.111.aaaa.com")
        
        
        
if __name__ == '__main__':
    unittest.main()
