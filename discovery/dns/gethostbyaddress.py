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


class gethostbyaddress:
    """ 
    Check with reverse dns query
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
        query = dns.client.lookupPointer(host)
        query.addCallback(self.__callSuccess, hd, job)
        query.addErrback(self.__callFailure, hd, job)
        
        hd.job(job, "waiting")



    def __callFailure(self, failure, hd, job):
        """
        If a hostbyaddress run fails
        """
        
        # failure.printTraceback()
        
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
