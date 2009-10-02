#!/usr/bin/env python
"""
hostmap

Author:
Alessandro `jekil` Tanasi <alessandro@tanasi.it>

License:

This file is part of hostmap.

hostmap is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

hostmap is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with hostmap.  If not, see <http://www.gnu.org/licenses/>.
"""



import socket
import lib.core.discovery.hostIntel as intel
from lib.output.logger import log
from lib.core.configuration import conf
from lib.core.hmException import *
import lib.core.controllers.jobController as jobController
from lib.common import *



class hostMap:
    """ 
    Host Discovery
    @todo: Write unit tests
    @author: Alessandro Tanasi
    @license: GNU Public License version 3
    @contact: alessandro@tanasi.it
    """
    
    
    
    def __init__(self, target, pluginController, debug=False):
        """
        Initialize target host details
        @params target: Target ip address for host discovery
        @params pluginController: An instance of class pluginController
        @params debug: Enable debug mode
        """
        
        # The name of the istance is the target ip address
        self.name = str(target)
        
        # Plugin controller
        self.pluginControl = pluginController
        
        # Tag used in all output messages
        self.tag = "HOSTDISCOVERY"
        
        # Host discovery debug mode
        self.debug = debug
        
        # Create a job controller
        self.jobControl = jobController.jobs()
        
        # Create a host intelligence model 
        self.host = intel.Host(target)
        
        if self.debug: 
            log.debug("Created new HostDiscovery for %s" % self.name, time=True, tag=self.tag)



    def getName(self):
        """
        Get instance name
        @return: Istance name
        """
        
        return self.name

    name = property(getName, None)


    def job(self, job, status):
        """
        Alter the status of a job (running plugin)
        @param job: Name of plugin
        @param status: Status of the plugin
        """
        
        self.jobControl.alter(job, status)
        
        # Check if all jobs are done, so Host Discovery is finished
        if self.jobControl.check(): 
            self.stop()



    def start(self, callback):
        """
        Starts Host Discovery
        @param callback: Function to call when the host discovery is done 
        """
        
        self.callback = callback
        
        if self.debug: log.debug("Host discovery started", time=True, tag=self.tag)
         
        # Start discovery
        self.notifyIp(self.name)




    def stop(self):
        """
        Stops Host Discovery
        """
        
        if self.debug: log.debug("Host discovery stopped", time=True, tag=self.tag)
        
        # End callback
        self.callback(self.host.results())



    def notifyIp(self, ip):
        """
        A new ip address has been detected, run all needed plugins.
        Steps:
        * Run all checks that get a ip as input
        @params ip: Ip address
        """
        
        self.pluginControl.runByIp(self, ip)



    def notifyDomain(self, domain):
        """
        A new domain is detected, run all needed plugins
        Steps:
        * Check if the domain ip address is the target ip
        * Run all checks that get a domain as input
        * Get the nameserver for that domain
        @params domain: Name of found domain
        """
        
        try:
            self.host.setDomain(domain)
            log.info("Found new domain: %s" % domain, time=True, tag=self.tag)
            self.pluginControl.runByDomain(self, domain)
            
            # The enumerated domain can be a valid virtual host
            self.notifyHost(domain)
        except hmResultException:
            return

        # Check if the domain is also an alias
        self.notifyHost(domain)



    def notifyNameserver(self, nameserver):
        """
        A new nameserver is detected, run all needed pluginsdomain
        Steps:
        * Check if the nameserver ip address is the target ip
        * Run all checks that get a nameserver as input
        * Try a zone transfer
        @bug: Fix docstring, this is an ip or a fqdn???
        @params nameserver: Nameserver found
        """

        try:
            self.host.setNameserver(nameserver)
            log.info("Found new nameserver: %s" % nameserver, time=True, tag=self.tag)
            self.pluginControl.runByNameserver(self, nameserver)
        except hmResultException:
            return

        # Check if the nameserver is runned by the target ip address
        self.notifyHost(nameserver)



    
    def notifyHostname(self, fqdn):
        """
        The reverse lookup DNS name has been enumerated
        """
        
        # Paranoid check
        if conf.Paranoid:
            try:
                if socket.gethostbyname(fqdn) != self.name: 
                    return
            # This exception is raised when a fqdn doesn't exist. 
            # socket.gaierror: (-5, 'No address associated with hostname')
            except socket.gaierror:
                return
            
        self.host.setHostname(fqdn)
        self.notifyHost(fqdn)
        
        
    def notifyHost(self, fqdn):
        """
        A new virtual host has been enumerated
        Steps:
        * Check if the host ip address is the target ip
        * Run all checks that get a hostname as input
        * Parse the domain name and notify a new domain (the hostname is also a domain name)
        @params fqdn: Fully qualified domain name of enumerated virtual host
        """
        
        # Paranoid check
        if conf.Paranoid:
            # Preventive check
            if fqdn is None: 
                return
            # Paranoid DNS check
            try:
                if socket.gethostbyname(fqdn) != self.name: 
                    return
            # This exception is raised when a fqdn doesn't exist. 
            # socket.gaierror: (-5, 'No address associated with hostname')
            except socket.gaierror:
                return
            
        try:
            self.host.setHost(fqdn)
            # TODO: host or virtual host?
            log.info("Found new hostname: %s" % fqdn, time=True, tag=self.tag)
            self.pluginControl.runByHostname(self, fqdn)
            
            # Grep domain and notify it
            domain = parseDomain(fqdn)
            self.notifyDomain(domain)
        except hmResultException:
            return
        
        
        
        # Are you searching a good ticketing system?
        # Visiting http://www.softblog.it you can find a lot of tickets that needs your analysis.