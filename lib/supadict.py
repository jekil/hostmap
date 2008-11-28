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



class supaDict(dict):
    """
    This class inherits from python dict and  create a Supa Dupa pointed dict. You can access keys and values using a pointed notation.
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
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
        @param key: Key to set
        @param value: Key's value to set  
        @todo: Add characters (like .) escaping
        """
        
        # TODO: escape points in key
        if self.__dict__.has_key(key):
            dict.__setattr__(self, key, value)
        else:
            self.__setitem__(key, value)
    
    
    
    def __getattr__(self, value):
        """
        Get a supa dupa item
        @param value: Key to get the value
        @return: The value of requested key
        """
        return self.__getitem__(value)
    


# And now, HOW TO MAKE  AN ITALIAN SPRITZ:
# while(drunk):
#   1) Take a glass
#   2) 3/4 of italian Tocaj wine 
#   3) 1/4 of Aperol
#   4) a piece of orange and a piece of lemon
#   5) drink! drink! drink! drunk!
