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



from twisted.names import client

import lib.core.outputDeflector as log
import lib.core.configuration as configuration
import lib.settings as settings



class dnsbruteforce:



    def require(self):
        """
        Sets plugin requirements
        """
        
        # Possible values are:
        # ip
        # domain
        # nameserver
        # hostname
        return "domain"



    def run(self, hd,  domain):
        """
        Start DNS hostnames brute forcing
        """
        
        # Configuration check
        if not configuration.conf.DNSBruteforce:
            log.out.debug("Skipping DNS bruteforce because it is disabled from command line")
            return
        if  configuration.conf.OnlyPassive: 
            log.out.debug("Skipping DNS bruteforce because it is enabled only passive checks")
            return
        
        self.job = "%s-%s" % (__name__,  domain)
        hd.job(self.job, "starting")
        
        # Load brute force names list
        hostsPath = settings.HOSTLIST
        
        # Local variables
        self.hostDict = {}
        self.hosts = []
        
        for host in file(hostsPath):
            # Sanitize
            host = host.replace("\n","").replace("\r","")
            # Compose fqdn
            fqdn = "%s.%s" % (host, domain)
            # Enqueue host
            self.hosts.append(fqdn)
            # Add to dict
            self.hostDict[fqdn] = None
            # Resolve
            query = client.getHostByName(fqdn)
            query.addCallback(self.__callSuccess, hd, fqdn)
            query.addErrback(self.__callFailure,hd, fqdn)
            
        hd.job(self.job, "waiting")
        
        # This piece of software is coded the night between 24 and 25 december, when i came back to home
        # drunk. A pleasure to Glen Grant.
    
    
    
    def __callFailure(self, failure, hd, fqdn):
        """
        If a brute force run fails
        """
        
        failure.printTraceback()
        
        # Remove host form todo host list
        self.hosts.remove(fqdn)
        
        # If todo host list is empty we have finished
        if len(self.hosts) == 0:
            # NOTE: This plugin cannot return a failure status because if only one query fails all plugin run is marked as failed
            hd.job(self.job, "done")



    def __callSuccess(self, success, hd, fqdn):
        """
        If a brute force run success
        """
        
        # Check if we found a new virtual host if ip address of brute forced host is the same of target host
        if self.target.getIp() == str(success):
            # Add found virtual host
            hd.notifyHost(fqdn)
            log.out.debug("Plugin %s added result: %s" % (__name__,  fqdn))
        
        # Remove host form todo host list
        self.hosts.remove(fqdn)
        
        # If todo host list is empty we have finished
        if len(self.hosts) == 0:
            hd.job(self.job, "done")
