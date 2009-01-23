#!/usr/bin/env python
#
#   hostmap
#
#   Author:
#    Alessandro `jekil` Tanasi <alessandro@tanasi.it>
#
#   License:
#
#    This file is part of hostmap.
#
#    hostmap is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    hostmap is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with hostmap.  If not, see <http://www.gnu.org/licenses/>.



import sys
from lib.core.configuration import *
from lib.output.outputDeflector import *
import lib.core.controllers.reactorController as reactor
import lib.core.controllers.pluginController as plugins
import lib.core.discovery.hostDiscovery as discovery
from lib.output.reporter import Report
from lib.singleton import Singleton



class Engine(Singleton):
    """ 
    Hostmap engine that handle an event based host discovery
    @author: Alessandro Tanasi
    @license: GNU Public License version 3
    @contact: alessandro@tanasi.it
    """

    
    
    def __init__(self, debug=False):
        """
        Initialize engine variables
        """

        Singleton().__init__()
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
