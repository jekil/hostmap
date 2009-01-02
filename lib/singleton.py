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



class Singleton(object):
    """
    A simple singleton pattern
    @see: http://code.activestate.com/recipes/52558/
    @todo: Write unit tests
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    
    
    class __impl:
        """ 
        Implementation of the singleton interface 
        """



        def spam(self):
            """ 
            Test method, return singleton id 
            """
            
            return id(self)



    # Storage for the instance reference
    __instance = None



    def __init__(self):
        """ 
        Create singleton instance 
        """
        
        # Check whether we already have an instance
        if Singleton.__instance is None:
            # Create and remember instance
            Singleton.__instance = Singleton.__impl()

        # Store instance reference as the only member in the handle
        self.__dict__['_Singleton__instance'] = Singleton.__instance



    def __getattr__(self, attr):
        """ 
        Delegate access to implementation 
        """
        
        return getattr(self.__instance, attr)



    def __setattr__(self, attr, value):
        """
        Delegate access to implementation 
        """
        
        return setattr(self.__instance, attr, value)
