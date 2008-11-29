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



class getnameserverbyns:



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
        Get the nameservers of a domain by dns NS lookup
        
        @paramas domain: domain name
        """
        
        job = "%s-%s" % (__name__,  domain)
        hd.job(job, "starting")
        
        # Query dns
        query = client.lookupNameservers(domain)
        query.addCallback(self.__callSuccess, hd,  job)
        query.addErrback(self.__callFailure, hd, job)       
        
        hd.job(job, "waiting")



    def __callFailure(self, failure, hd,  job):
        """
        If a nameservers run fails
        """
        
        failure.printTraceback()
        
        hd.job(job, "failure")



    def __callSuccess(self, success, hd,  job):
        """
        If a nameservers run success
        """
        
        # Extract nameservers fqdn from response
        for values in success:
            for ns in values:
                log.out.debug("Plugin %s added result: %s" % (__name__,  str(ns.payload.name)))
                hd.notifyDomain(str(ns.payload.name))
        
        hd.job(job, "done")
