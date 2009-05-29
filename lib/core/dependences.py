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



"""
Checks if required libraries are installed
@author: Alessandro Tanasi
@license: GNU Public License version 3
@contact: alessandro@tanasi.it
"""



from lib.output.logger import log
from lib.core.hmException import hmImportException



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
