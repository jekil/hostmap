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



import sys
from lib.core.configuration import *
from lib.output.outputDeflector import *
import lib.core.controllers.reactorController as reactor
import lib.core.controllers.pluginController as plugins
import lib.core.controllers.jobController as jobs
import lib.core.discovery.hostDiscovery as discovery
from lib.output.reporter import Report
from lib.singleton import *



class engine():
    """ 
    Hostmap engine that handle an event based host discovery
    @author: Alessandro Tanasi
    @license: Private software
    @contact: alessandro@tanasi.it
    @todo: Add singleton
    """

    
    
    def __init__(self, debug=False):
        """
        Initialize engine variables
        """
        
        # Tag used in all output messages
        self.tag = "ENGINE"
        
        # Host discovery debug mode
        self.debug = debug

  
    
    def start(self):
        """
        Start the engine and its jobs
        """
        
        log.debug("Engine started", time=True, tag=self.tag)
        
        # Load plugins
        pluginControl = plugins.plugin()
        
        # For each target spawn a host discovery controller
        hostDiscovery = discovery.hostMap(conf.Target, pluginControl)
        hostDiscovery.start(self.stop)
        
        # Start Twisted Reactor - let's go!
        reactor.start()



    def stop(self, results=None):
        """
        Stop engine and its jobs
        """
        
        # Stop Twisted Reactor
        reactor.stop()
        
        log.debug("Engine stopped", time=True, tag=self.tag)

        # Print results
        if results: 
            Report(results)
    
        # Here we must exit
        sys.exit
        
        
        
en = engine()
