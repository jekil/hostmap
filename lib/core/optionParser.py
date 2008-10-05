#!/usr/bin/env python
#
#   hostmap
#   http://hostmap.sourceforge.net/
#
#   Author:
#    Alessandro `jekil` Tanasi <alessandro@tanasi.it>
#
#   License:
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA



from optparse import OptionParser
from optparse import OptionError

from lib.supadict import supaDict
import lib.core.configuration as configuration



"""
Parse command line 

@author: Alessandro Tanasi <alessandro@tanasi.it>
"""


def parseArgs():
    """
    Command line parsing function. Parse command line and create a configuration dict.
    """
    
    # Menu default string
    usage = "usage: %prog [options] -t target"
    
    # Create menu and parser
    parser = OptionParser(usage)
    parser.add_option( "--without-zonetransfer",
                                help="disable DNS zone transfer",
                                action="store_false",
                                dest="dnszonetransfer",
                                default=True)
    parser.add_option( "--without-bruteforce",
                                help="disable DNS bruteforcing",
                                action="store_false",
                                dest="dnsbruteforce",
                                default=True)
    parser.add_option( "--without-webservercheck",
                                help="disable web server check",
                                action="store_false",
                                dest="webservercheck",
                                default=True)
    parser.add_option( "--without-be-paranoid",
                                help="don't check the results consistency",
                                action="store_false",
                                dest="paranoid",
                                default=True)
    parser.add_option( "--only-passive",
                                help="passive discovery, don't make network activity to the target network",
                                action="store_true",
                                dest="onlypassive",
                                default=False)
    parser.add_option( "--only-active",
                                help="active discovery, skip passive discovery",
                                action="store_true",
                                dest="onlyactive",
                                default=False)
    parser.add_option("-d", "--target-dns",
                                help="use this DNS server for queries",
                                action="store",
                                type="string",
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

    options, args = parser.parse_args()
    
   # TODO: handle options.target is None:

    # Create configuation dict
    conf = supaDict()
    
    # Set configuration
    # Global options
    conf.Target = options.target
    conf.Verbose = options.verbose
    conf.OnlyPassive = options.onlypassive
    conf.OnlyActive = options.onlyactive
    conf.Paranoid = options.paranoid
    # DNS module options
    conf.DNSZoneTransfer = options.dnszonetransfer
    conf.DNSBruteforce = options.dnsbruteforce
    conf.DNS= options.dns
    # Web module
    conf.WebServerCheck = options.webservercheck

    # Set global configuration
    configuration.conf = conf 
