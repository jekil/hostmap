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
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA



import time



class supaDict(dict):
    """
    This class inherits from python dict and  create a Supa Dupa pointed dict. You can access keys and values using a pointed notation.
    """
    
    def __init__(self):
        """
        Creates a new Supa Dupa dict
        """
        
        # Create an empty dict inheriting from Python dict class
        sdict = {}
        dict.__init__(self, sdict)
    
    
    
    def __setattr__(self,  key,  value):
        """
        Set a supa dupa item
        """
        
        # TODO: escape points in key
        if self.__dict__.has_key(key):
            dict.__setattr__(self, key, value)
        else:
            self.__setitem__(key, value)
    
    
    
    def __getattr__(self, value):
        """
        Get a supa dupa item
        """
        return self.__getitem__(value)
    


# And now, HOW TO MAKE  AN ITALIAN SPRITZ:
# while(drunk):
#   1) Take a glass
#   2) 3/4 of italian Tocaj wine 
#   3) 1/4 of Aperol
#   4) a piece of orange and a piece of lemon
#   5) drink! drunk!
