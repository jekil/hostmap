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



from lib.supadict import supaDict
from lib.singleton import Singleton



class Configuration(supaDict, Singleton):
    """
    User configuration / options
    @author: Alessandro Tanasi
    @license: GNU Public License version 3
    @contact: alessandro@tanasi.it
    """



    def __getattr__(self, value):
        """
        Override supaDict to return None if a option isn't setted
        @param value: Key to get the value
        @return: The value of requested key
        """
        
        try:
            return supaDict.__getattr__(self, value)
        except KeyError:
            return None



conf = Configuration()
