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
#    along with hostmap.  If not, see <http://www.gnu.org/licenses/>.



from twisted.names import client
from lib.output.logger import log


class getmxbydomain:
    """ 
    Get the mx for a domain
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
