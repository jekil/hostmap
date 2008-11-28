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
