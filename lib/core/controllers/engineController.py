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



from lib.core.configuration import *
from lib.core.outputDeflector import *
import lib.core.controllers.reactorController as reactor
import lib.core.controllers.pluginController as plugins
import lib.core.controllers.jobController as jobs
import lib.core.discovery.hostDiscovery as discovery
from lib.singleton import *



class engine():
    """ 
    Hostmap engine that handle an event based host discovery
    @author: Alessandro Tanasi
    @license: Private software
    @contact: alessandro@tanasi.it
    @todo: Add singleton
    """

    
    
    def __init__(self,  debug = False):
        """
        Initialize engine variables
        """
        
        # Tag used in all output messages
        self.tag = "ENGINE"
        
        # Host discovery debug mode
        self.debug = debug

        
        # TODO: remove this
        # Start jobs without dependences
        #import dns
        #self.d = dns.dns(self, self.target)
        #self.d.getHostbyaddress(self.target.getIp())

        #import web
        #self.w = web.web(self, self.target,  self.conf)
        #self.w.searchLiveByAddress(self.target.getIp())
        #self.w.searchRusCertByAddress(self.target.getIp())
        #self.w.searchDomainsdbByAddress(self.target.getIp())
        #self.w.searchGigablastByAddress(self.target.getIp())
        #self.w.searchRobtexByAddress(self.target.getIp())
        #self.w.searchTomdnsByAddress(self.target.getIp())
        #self.w.searchWebhostingByAddress(self.target.getIp())
        #self.w.searchWebmaxByAddress(self.target.getIp())



    
    
    
  
    
    def start(self):
        """
        Start the engine and its jobs
        """
        
        log.debug("Engine started", time=True, tag=self.tag)
        
        # Load plugins
        pluginControl = plugins.plugin(debug=True)
        
        # For each target spawn a host discovery controller
        #TODO: dict for track status
        #for target in configuration.conf.Target:
        hostDiscovery = discovery.hostMap(conf.Target, pluginControl, debug=True)
        hostDiscovery.start(self.stop)
        
        # Start Twisted Reactor - let's go!
        reactor.start()



    def stop(self):
        """
        Stop engine and its jobs
        """
        
        # Stop Twisted Reactor
        reactor.stop()
        
        log.debug("Engine stopped",  time=True,  tag=self.tag)
    
    
# TODO: Here we must exit
        import sys
        sys.exit
en = engine()
