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
from lib.output.outputDeflector import log


class getmxbydomain:
    """ 
    Get the mx for a domain
    @author: Alessandro Tanasi
    @license: Private software
    @contact: alessandro@tanasi.it
    """


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



    def run(self, hd, domain):
        """
        Get a mx for a domain
        @params hd: Host discovery controller
        @params ip: domain name
        """
        
        job = "%s-%s" % (__name__, domain)
        hd.job(job, "starting")

        # Query dns
        query = client.lookupMailExchange(domain)
        query.addCallback(self.__callSuccess, hd, job)
        query.addErrback(self.__callFailure, hd, job)
        
        hd.job(job, "waiting")



    def __callFailure(self, failure, hd, job):
        """
        If a run fails
        """
        
        # failure.printTraceback()
        
        hd.job(job, "failure")



    def __callSuccess(self, success, hd, job):
        """
        If a run success
        """
        
        # Set fqdn
        fqdn = str(success[0][0].payload.name)
        log.debug("Plugin %s added result: %s" % (__name__, fqdn))
        hd.notifyHost(fqdn)
        hd.job(job, "done")
