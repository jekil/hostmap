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


import os
import sys
from optparse import OptionParser
from optparse import OptionError
from lib.core.hmException import hmOptionException
from lib.core.configuration import conf
from lib.settings import VERSION, loadFromFile



"""
Parse command line 
@license: GNU Public License version 3
@author: Alessandro Tanasi 
@contact: alessandro@tanasi.it
"""


def initialize():
    """
    Initialize hostmap configaration
    """
    
    # Load paths, even if in py2exe
    # Reference: http://www.py2exe.org/index.cgi/WhereAmI
    if hasattr(sys, "frozen"):
        conf.root = os.path.dirname(unicode(sys.executable, sys.getfilesystemencoding()))
    else:
        conf.root = os.path.dirname(os.path.realpath(__file__))
    
    
def parseArgs():
    """
    Command line parsing function. Parse command line and create a configuration dict.
    @raise hmOptionException: if target is not specified
    """

    # Load by default configuration from file
    loadFromFile()
    
    # Menu default string
    usage = "%s [options] -t target" % sys.argv[0]
    
    # Create menu and parser
    parser = OptionParser(usage=usage, version=VERSION)
    parser.add_option( "--with-zonetransfer",
                                help="enable DNS zone transfer check",
                                action="store_true",
                                dest="dnszonetransfer",
                                default=False)
    parser.add_option( "--without-bruteforce",
                                help="disable DNS bruteforcing",
                                action="store_false",
                                dest="dnsbruteforce",
                                default=True)
    parser.add_option("--bruteforce-level",
                                help="set bruteforce aggressivity, values are lite, custom or full (default is lite)",
                                action="store",
                                type="string",
                                default="lite",
                                dest="dnsbruteforcelevel")
    parser.add_option( "--without-be-paranoid",
                                help="don't check the results consistency",
                                action="store_false",
                                dest="paranoid",
                                default=True)
    parser.add_option("--http-ports",
                                help="set a comma separated list of custom HTTP ports to check",
                                action="store",
                                type="string",
                                default=None,
                                dest="httpports")
    parser.add_option( "--only-passive",
                                help="passive discovery, don't make network activity to the target network",
                                action="store_true",
                                dest="onlypassive",
                                default=False)
    parser.add_option("-d", "--dns",
                                help="set a comma separated list of DNS servers IP addresses to use instead of system defaults",
                                action="store",
                                type="string",
                                default=None,
                                dest="dns")
    parser.add_option("-v", "--verbose",
                                help="set verbose mode",
                                action="store_true",
                                dest="verbose",
                                default=False)
    parser.add_option("-t", "--target",
                                help="set target domain",
                                action="store",
                                type="string",
                                dest="target")

    (options, _) = parser.parse_args()
    
    # No target selected
    if options.target is None:
        raise hmOptionException("No target selected. You must select a target with -t option.")
    
    # Set configuration
    # Global options
    conf.Target = options.target
    conf.Verbose = options.verbose
    conf.OnlyPassive = options.onlypassive
    conf.Paranoid = options.paranoid
    conf.DNS = options.dns
    if options.httpports:
        conf.HttpPorts = options.httpports.split(",")
        
    # DNS module options
    conf.DNSZoneTransfer = options.dnszonetransfer
    conf.DNSBruteforce = options.dnsbruteforce
    conf.DNSBruteforceLevel = options.dnsbruteforcelevel
