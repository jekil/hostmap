#!/usr/bin/env python
#
#   hostmap
#
#   Author:
#    Alessandro `jekil` Tanasi <alessandro@tanasi.it>
#
#   License:
#
#    This file is part of hostmap.
#
#    hostmap is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    hostmap is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with hostmap.  If not, see <http://www.gnu.org/licenses/>.



class hmException(Exception):
    """
    Generic HostMap excpetion
    @license: GNU Public License version 3
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    def __init__(self, value):
        Exception.__init__( self )
        self.value = value
    
    def __str__(self):
        return self.value
    


class hmImportException(hmException):
    """
    HostMap Import excpetion
    @license: GNU Public License version 3
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    pass



class hmOptionException(hmException):
    """
    HostMap Option excpetion
    @license: GNU Public License version 3
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    pass



class hmFileException(hmException):
    """
    HostMap File excpetion
    @license: GNU Public License version 3
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    pass



class hmPluginException(hmException):
    """
    HostMap Plugin excpetion
    @license: GNU Public License version 3
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    pass



class hmParserException(hmException):
    """
    HostMap parser excpetion
    @license: GNU Public License version 3
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    pass



class hmResultException(hmException):
    """
    An exception in the enumerated result
    @license: GNU Public License version 3
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    pass