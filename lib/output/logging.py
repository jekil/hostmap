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

import logging
import sys
from time import strftime
from lib.core.configuration import conf

class Logger():
    """
    Custom hostmap logger
    @author: Alessandro Tanasi
    @license: GNU Public License version 3
    @contact: alessandro@tanasi.it
    @todo: Use singleton
    @todo: Save log to file
    """
        
    def __init__(self):
        # Add custom logging channels
        ogging.addLevelName(15, "VERBOSE")
        logging.addLevelName(7, "TRAFFIC")
        # Create logger
        self.logger = logging.getLogger("hostmap")
        handler = logging.StreamHandler(sys.stdout)
        self.logger.addHandler(handler)
        # Set logging level due to user logging options
        if conf.Verbose:
            self.logger.setLevel(logging.VERBOSE)
        self.logger.setLevel(logging.WARN)

    def _message(self, text, cr=True, time=False, tag=None):
        """
        Format a generic message      
        @params text: Message text
        @params cr: Presence of new line
        @params time: Print timestamp
        @params tag: Type
        """
        # Add a tag (example [ENGINE] yadda yadda)
        if tag: 
            text = "[%s] %s" % (tag, text)
        # Add timestamp
        if time: 
            text = "[%s] %s" % (strftime("%X"), text)
        # Encode message in unicode
        text = unicode(text, errors='replace')
        return text

    def info(self, text, cr=True, time=False, tag=None):
        """
        A info message
        @params text: Message text
        @params cr: Presence of new line
        @params time: Print timestamp
        @params tag: Type
        """
        self.logger.info(self._message(text, cr, time, tag))

    def debug(self, text, cr=True, time=False, tag=None):
        """
        A debug message
        @params text: Message text
        @params cr: Presence of new line
        @params time: Print timestamp
        @params tag: Type
        """        
        self.logger.debug(self._message(text, cr, time, tag))
    
    def verbose(self, text, cr=True, time=False, tag=None):
        """
        A verbose message
        @params text: Message text
        @params cr: Presence of new line
        @params time: Print timestamp
        @params tag: Type
        """        
        self.logger.verbose(self._message(text, cr, time, tag))
        
    def traffic(self, text, cr=True, time=False, tag=None):
        """
        A traffic message
        @params text: Message text
        @params cr: Presence of new line
        @params time: Print timestamp
        @params tag: Type
        """        
        self.logger.traffic(self._message(text, cr, time, tag))

    def warn(self, text, cr=True, time=False, tag=None):
        """
        A warning message
        @params text: Message text
        @params cr: Presence of new line
        @params time: Print timestamp
        @params tag: Type
        """
        self.logger.warn(self._message(text, cr, time, tag))
        
    def error(self, text, cr=True, time=False, tag=None):
        """
        An error message
        @params text: Message text
        @params cr: Presence of new line
        @params time: Print timestamp
        @params tag: Type
        """
        self.logger.error(self._message(text, cr, time, tag))

log = Logger()