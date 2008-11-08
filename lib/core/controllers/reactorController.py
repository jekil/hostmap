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

import lib.core.outputDeflector as log



"""
Manage Twisted reactor

@author: Alessandro Tanasi <alessandro@tanasi.it>
"""



def start():
    """
    Start Twisted reactor
    """
    
    log.out.debug("Reactor started",  time=True, tag="REACTOR")
    reactor.run()



def stop():
    """
    Stop Twisted reactor
    """
    
    log.out.debug("Reactor stopped",  time=True, tag="REACTOR")
    reactor.stop()
