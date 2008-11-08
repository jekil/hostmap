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



import lib.intel as intel
import lib.core.outputDeflector as log
import lib.core.configuration as configuration
import lib.core.controllers.jobController as jobController
from lib.common import *



class hostMap:
    """ 
    Host Discovery

    @author: Alessandro Tanasi
    """
    
    
    
    def __init__(self,  target, pluginController,   debug = False):
        """
        Initialize target host details
        
        @params target: target ip address for host discovery
        @params pluginController: an instance of class pluginController
        @params debug: enable debug mode
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
        self.jobControl = jobController.jobs(debug=True)
        
        # Create a host intelligence model 
        self.host = intel.Host(self,  target)
        
        if self.debug:
            log.out.debug("Created new HostDiscovery for %s" % self.name,  time=True, tag=self.tag)



    def getName(self):
        """
        Get instance name
        """
        
        return self.name



    def job(self,  job,  status):
        """
        Get the status of each plugin
        
        @param job: name of plugin
        @param status: status of the plugin
        """
        
        self.jobControl.alter(job,  status)
        
        # Check if all jobs are done, so Host Discovery is finished
        if self.jobControl.check():
            self.stop()



    def start(self):
        """
        Starts Host Discovery
        """
        
        if self.debug:
            log.out.debug("Host discovery started",  time=True, tag=self.tag)
         
        # Start discovery
        self.notifyIp(self.name)




    def stop(self):
        """
        Stops Host Discovery
        """
        
        if self.debug:
            log.out.debug("Host discovery stopped",  time=True, tag=self.tag)
        self.host.status()



    def notifyIp(self, ip):
        """
        A new ip address has been detected, run all needed plugins
        
        @params ip: ip address
        """
        
        self.pluginControl.runByIp(self, ip)



    def notifyDomain(self, domain):
        """
        A new domain is detected, run all needed plugins
        
        @params domain: name of found domain
        """
        
        # Check if this domain has been already discovered
        if self.host.addDomain(domain):
            log.out.info("Found new domain: %s" % domain,  time=True, tag=self.tag)
            self.pluginControl.runByDomain(self, domain)
        # Get nameservers
        #if not self.conf.OnlyPassive:
        #   self.d.getNameservers(domain)



    def notifyNameserver(self, nameserver):
        """
        A new nameserver is detected, run all needed plugins
        
        @params nameserver: nameserver found
        """
        
        # Check if this domain has been already discovered
        if self.host.addNameserver(domain):
            log.out.info("Found new nameserver: %s" % domain,  time=True, tag=self.tag)
            self.pluginControl.runByNameserver(self, nameserver)
        # Check if a name server is the target
        #if not self.conf.OnlyPassive:
        #    self.d.getHostbyName(nameserver)
        #    # TODO: remove
        #    nameserser="casetta.lan"
        #    if self.conf.DNSZoneTransfer:
        #        self.d.getZoneAxfr(nameserver)


    
    def notifyHost(self, fqdn):
        """
        A new virtual host has been enumerated
        
        @params fqdn: fully qualified domain name of enumerated virtual host
        """
        
        # Check if this virtual host has been already discovered
        if self.host.addHost(fqdn):
            # TODO: host or virtual host?
            log.out.info("Found new host: %s" % fqdn,  time=True, tag=self.tag)
            self.pluginControl.runByHostname(self, fqdn)
            
            # Grep domain and notify it
            domain = parseDomain(fqdn)
            self.notifyDomain(domain)
        
        
        
        # Are you searching a good ticketing system?
        # Visiting http://www.softblog.it you can find a lot of tickets that needs your analysis.
