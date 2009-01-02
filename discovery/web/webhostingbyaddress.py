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
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.



import re
from twisted.web import client
from lib.output.outputDeflector import log



class webhostingbyaddress:
    """ 
    Check against drobtex
    @author: Alessandro Tanasi
    @license: Private software
    @contact: alessandro@tanasi.it
    @bug: At 29/11/2008 this website has a captcha
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
        Query Webhosting using dork ip: to ge a list of domains
        """
    
        self.job = "%s-%s" % (__name__, ip)
        hd.job(self.job, "starting")
        
        # Compose urltomdns
        url = "http://whois.webhosting.info/%s" % ip
        
        # Search
        query = client.getPage(url)
        query.addCallback(self.__callSuccess, hd)
        query.addErrback(self.__callFailure, hd)
        
        hd.job(self.job, "waiting")
    


    def __callFailure(self, failure, hd):
        """
        If a Webhosting search run fails
        """
        
        # failure.printTraceback()
        
        hd.job(self.job, "failure")


    def __callSuccess(self, success, hd):
        """
        If a Webhosting run success
        """
        
        # Regexp to catch fqdn
        regexp = "\"http://whois.webhosting.info/.*?.\">(.*?)[.]<"
        # Cast object, paranoid mode
        page = str(success)
        # Grep
        results = re.findall(regexp, page, re.I | re.M)

        # Add new found hosts
        for domain in set(results):
            hd.notifyDomain(domain)
            log.debug("Plugin %s added result: %s" % (__name__, domain))
        
        hd.job(self.job, "done")
