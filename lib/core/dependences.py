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
#    along with this program; if not, write to the Free Softwareself.setDomain(parseDomain(fqdn))
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA



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
