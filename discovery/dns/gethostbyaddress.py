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
from lib.core.outputDeflector import log


class gethostbyaddress:
    """ 
    Check with reverse dns query
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
        return "ip"



    def run(self, hd, ip):
        """
        Get a fqdn from a ipv4 address
        @params hd: Host discovery controller
        @params ip: ipv4 address 
        """
        
        job = "%s-%s" % (__name__, ip)
        hd.job(job, "starting")
        
        # Create hostname in-addr.arpa
        host = '.'.join(ip.split('.')[::-1]) + '.in-addr.arpa'

        # Query dns
        query = client.lookupPointer(host)
        query.addCallback(self.__callSuccess, hd, job)
        query.addErrback(self.__callFailure, hd, job)
        
        hd.job(job, "waiting")



    def __callFailure(self, failure, hd, job):
        """
        If a hostbyaddress run fails
        """
        
        failure.printTraceback()
        
        hd.job(job, "failure")



    def __callSuccess(self, success, hd, job):
        """
        If a hostbyaddress run success
        """
        
        # Set fqdn
        fqdn = str(success[0][0].payload.name)
        log.debug("Plugin %s added result: %s" % (__name__, fqdn))
        hd.notifyHostname(fqdn)
        hd.job(job, "done")
