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
Internal hostmap configuration file. Some environment variables can be changed here, but a normal user doesn't need to change this file.
@license: GNU Public License version 3
@author: Alessandro Tanasi
@contact: alessandro@tanasi.it
"""

import os
from ConfigParser import NoSectionError
from ConfigParser import ConfigParser
from lib.core.hmException import hmOptionException
from lib.core.configuration import conf

# Version specific
VERSION = "0.2"
CODENAME = "tapioca"

# Dictionaries settings
# TODO: uniform the path separator
HOSTLISTLITE = "dictionaries/hostnames-lite.txt"
HOSTLISTCUSTOM = "dictionaries/hostnames-custom.txt"
HOSTLISTFULL = "dictionaries/hostnames-full.txt"

# Plugins settings
PLUGINDIR = "discovery"
    

def loadFromFile(file="hostmap.conf"):
    """
    Load setting from file.
    @raise hmOptionException: If missing file or mandatory section.
    """
    
    # Check for file
    if not (os.path.exists(file) and os.path.isfile(file)):
        raise hmOptionException, "File hostmap.conf not found."
    
    config = ConfigParser()
    config.read(file)

    # Check for mandatory settings section
    if not config.has_section("Settings"):
        raise hmOptionException, "Settings section in the configuration file is mandatory"

    # Load ports
    if not config.has_option("Settings", "ports"):
        raise hmOptionException, "The option 'ports' is mandatory in the 'Settings' section."
    else:
        ports = config.get("Settings", "ports").replace(" ","").split(",")
        if ports != [""]:
            conf.HttpPorts = ports
        else:
            raise hmOptionException, "The option 'ports' is mandatory in the 'Settings' section."
        
    # Load Bing API
    if config.has_option("Settings", "bingApiKey"):
        conf.bingApiKey = config.get("Settings", "bingApiKey")