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



from lib.networking import dns
from lib.output.logger import log



class getnameserverbydomain:
    """ 
    Get the nameservers for a domain
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
        return "domain"



    def run(self, hd,  domain):
        """
        Get the nameservers of a domain by dns NS lookup
        @paramas domain: domain name
        """
        
        job = "%s-%s" % (__name__, domain)
        hd.job(job, "starting")
        
        # Query dns
        query = dns.client.lookupNameservers(domain)
        query.addCallback(self.__callSuccess, hd, job)
        query.addErrback(self.__callFailure, hd, job)       
        
        hd.job(job, "waiting")



    def __callFailure(self, failure, hd, job):
        """
        If a nameservers run fails
        """
        
        # failure.printTraceback()
        
        hd.job(job, "failure")



    def __callSuccess(self, success, hd, job):
        """
        If a nameservers run success
        """

        # Extract nameservers fqdn from response
        for values in success:
            for ns in values:
                log.debug("Plugin %s added result: %s" % (__name__, str(ns.payload.name)))
                hd.notifyNameserver(str(ns.payload.name))
        
        hd.job(job, "done")
