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
    @license: Private licensing
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
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    pass



class hmOptionException(hmException):
    """
    HostMap Option excpetion
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    pass



class hmFileException(hmException):
    """
    HostMap File excpetion
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    pass



class hmPluginException(hmException):
    """
    HostMap Plugin excpetion
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    pass

class hmParserException(hmException):
    """
    HostMap parser excpetion
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    pass

class hmDupException(hmException):
    """
    HostMap duplicate exception
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    pass