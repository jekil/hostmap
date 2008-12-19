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



from lib.supadict import supaDict
from lib.singleton import Singleton



class Configuration(supaDict, Singleton):
    """
    User configuration / options
    @author: Alessandro Tanasi
    @license: Private software
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
