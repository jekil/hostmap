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
from lib.core.configuration import conf
from lib.output.outputDeflector import log


class dnsaxfrzonetransfer:
    """ 
    Tries a AXFR zone transfer
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
        return "nameserver"



    def run(self, hd, nameserver):
        """
        Try a dns zone transfer
        @params hd: Host discovery controller
        @params nameserver: Nameserver 
        """
        
        # Configuration check
        if not conf.DNSZoneTransfer:
            log.debug("Skipping DNS Zone transfer because it is disabled by default, you must enable it from from command line")
            return
        if conf.OnlyPassive: 
            log.debug("Skipping DNS Zone transfer because it is enabled only passive checks")
            return
       
        job = "dnsaxfr-%s" % nameserver
        hd.job(job, "starting")

        # Query dns
        query = client.lookupZone(nameserver)
        query.addCallback(self.__callSuccess, hd, job)
        query.addErrback(self.__callFailure, hd, job)
        
        hd.job(job, "waiting")



    def __callFailure(self, failure, hd, job):
        """
        If a zone transfer run fails
        """
        
        # failure.printTraceback()
        
        hd.job(job, "failure")



    def __callSuccess(self, success, hd, job):
        """
        If a dns zone transfer run success
        """
    
        log.info("Nameserver is vulnerable to DNS AXFR zone transfer, use a transfer to get a dump")
        hd.job(job, "done")
