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



class hmException(Exception):
    """
    Generic HostMap excpetion
    @author: Alessandro Tanasi <alessandro@tanasi.it>
    """
    
    def __init__(self, value):
        Exception.__init__( self )
        self.value = value
    
    def __str__(self):
        return self.value
    


class hmImportException(hmException):
    """
    HostMap Import excpetion
    @author: Alessandro Tanasi <alessandro@tanasi.it>
    """
    
    pass