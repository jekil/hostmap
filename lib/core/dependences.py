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



"""
Checks if required libraries are installed

@author: Alessandro Tanasi <alessandro@tanasi.it>
"""



import sys
import outputDeflector as log



def check():
    """
    Checks for depencies
    """
    
    log.out.debug("Checking dependencies...")
    
    # Checks for Twisted 
    try:
        import twisted
    except Exception, e:
        print "ERROR: Twisted library not found. Aborting"
        print "Install Twisted library (http://twistedmatrix.com). In Debian like systems you can type apt-get install python-twisted"
        print "Aborting."
        sys.exit(1)
    
    log.out.debug("All dependencies ok!")
