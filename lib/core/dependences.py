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
@author:       Alessandro Tanasi
@license:      Private software
@contact:      alessandro@tanasi.it
"""



from lib.output.outputDeflector import log
from lib.core.hmException import *



def check():
    """
    Checks for dependencies.
    @raise hmImportException: If dependencies aren't meets
    """
    
    log.debug("Checking dependencies...")
    
    # Import Twisted 
    log.debug("Importing Twisted framework")
    try:
        import twisted
    except Exception:
        raise hmImportException("Twisted library not found. Install Twisted library (http://twistedmatrix.com). In Debian like systems you can type apt-get install python-twisted")
    
    log.debug("All dependencies ok!")
