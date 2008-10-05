#!/usr/bin/env python
#
#   hostmap
#   http://hostmap.sourceforge.net/
#
#   Author:
#    Alessandro `jekil` Tanasi <alessandro@tanasi.it>
#
#   License:
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA



import lib.core.configuration as configuration
import lib.core.outputDeflector as log
import lib.core.controllers.reactorController as reactor
import lib.core.controllers.pluginController as plugins
import lib.core.controllers.jobController as jobs
import lib.core.discovery.hostDiscovery as discovery



class engine:
    """ 
    Hostmap engine that handle an event based host discovery

    @author: Alessandro Tanasi
    """

    
    
    def __init__(self,  debug = False):
        """
        Initialize engine variables
        """
        
        # Tag used in all output messages
        self.tag = "ENGINE"
        
        # Host discovery debug mode
        self.debug = debug



    def __jobStart(self):
        """
        Start all jobs
        """    
        
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
        
        log.out.debug("Engine started",  time=True,  tag=self.tag)
        
        # Load plugins
        pluginControl = plugins.plugin(debug=True)
        
        # For each target spawn a host discovery controller
        #TODO: dict for track status
        #for target in configuration.conf.Target:
        hostDiscovery = discovery.hostMap(configuration.conf.Target, pluginControl,   debug=True)
        hostDiscovery.start()
        
        # Start Twisted Reactor - let's go!
        reactor.start()



    def stop(self):
        """
        Stop engine and its jobs
        """
        
        # Stop Twisted Reactor
        reactor.stop()
        
        log.out.debug("Engine stopped",  time=True,  tag=self.tag)
    
    
# This class must be a Singleton. There is only one engine.
en = engine()
