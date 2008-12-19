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



from twisted.internet import reactor
from lib.output.outputDeflector import *



"""
Manage Twisted reactor
@author: Alessandro Tanasi
@license: Private software
@contact: alessandro@tanasi.it
"""



def start():
    """
    Start Twisted reactor
    """
    
    log.debug("Reactor started", time=True, tag="REACTOR")
    reactor.run()



def stop():
    """
    Stop Twisted reactor
    """
    
    log.debug("Reactor stopped", time=True, tag="REACTOR")
    reactor.stop()
