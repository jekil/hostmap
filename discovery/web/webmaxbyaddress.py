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



import re
from twisted.web import client
from lib.output.outputDeflector import log



class webmaxbyaddress:
    """ 
    Check against webmax
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
        Query Webmax using dork ip: to ge a list of domains
        """
    
        self.job = "%s-%s" % (__name__, ip)
        hd.job(self.job, "starting")
        
        # Compose url
        url = "http://www.web-max.ca/tools/domain.php?domain=&exact=1&byip=Search+by+specific+IP&ip_from=&ip_to=&ip=%s" % ip
        
        # Search
        query = client.getPage(url)
        query.addCallback(self.__callSuccess, hd)
        query.addErrback(self.__callFailure, hd)
        
        hd.job(self.job, "waiting")
    


    def __callFailure(self, failure, hd):
        """
        If a Webmax search run fails
        """
        
        # failure.printTraceback()
        
        hd.job(self.job, "failure")


    def __callSuccess(self, success, hd):
        """
        If a Webmax run success
        """
        # TODO: test this
        # Regexp to catch fqdn
        regexp = "align=\"absmiddle\">&nbsp;<a href=\"http://(.*?)\" target=\"_blank\">"
        # Cast object, paranoid mode
        page = str(success)
        # Grep
        results = re.findall(regexp, page, re.I | re.M)
        
        # Add new found hosts
        for domain in set(results):
            hd.notifyDomain(domain)
            log.debug("Plugin %s added result: %s" % (__name__, domain))
        
        hd.job(self.job, "done")
