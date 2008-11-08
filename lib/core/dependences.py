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



import outputDeflector as log
from controllers.hmException import *



def check():
    """
    Checks for dependencies.
    @return: hmImportException if dependencies aren't meets
    """
    
    log.out.debug("Checking dependencies...")
    
    # Import Twisted 
    log.out.debug("Importing Twisted framework")
    try:
        import twisted
    except Exception, e:
        raise hmImportException("Twisted library not found. Install Twisted library (http://twistedmatrix.com). In Debian like systems you can type apt-get install python-twisted")
    
    log.out.debug("All dependencies ok!")
