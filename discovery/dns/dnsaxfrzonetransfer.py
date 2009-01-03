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
#    along with hostmap.  If not, see <http://www.gnu.org/licenses/>.>



from twisted.names import client
from lib.core.configuration import conf
from lib.output.outputDeflector import log


class dnsaxfrzonetransfer:
    """ 
    Tries a AXFR zone transfer
    @author: Alessandro Tanasi
    @license: GNU Public License version 3
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
