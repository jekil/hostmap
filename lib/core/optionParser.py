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



from optparse import OptionParser
from optparse import OptionError
from lib.core.hmException import *
from lib.core.configuration import conf



"""
Parse command line 
@license: Private software
@author: Alessandro Tanasi 
@contact: alessandro@tanasi.it
"""


def parseArgs():
    """
    Command line parsing function. Parse command line and create a configuration dict.
    @raise hmOptionException: if target is not specified
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
    # TODO: function not implemented now
    #parser.add_option( "--without-webservercheck",
    #                            help="disable web server check",
    #                            action="store_false",
    #                            dest="webservercheck",
    #                            default=True)
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
    # TODO: not implemented yet
    #parser.add_option("-d", "--target-dns",
    #                            help="use this DNS server for queries",
    #                            action="store",
    #                            type="string",
    #                            dest="dns")
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

    options, _ = parser.parse_args()
    
    # No target selected
    if options.target is None:
        raise hmOptionException("No target selected. You must select a target with -t option.")
    
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
    #conf.DNS = options.dns
    # Web module
    #conf.WebServerCheck = options.webservercheck
