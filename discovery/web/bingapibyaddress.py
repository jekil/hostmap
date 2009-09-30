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
from urlparse import urlparse
from twisted.web import client
from lib.output.logger import log
from lib.core.configuration import conf



class bingapibyaddress:
    """ 
    Check against microsoft Bing using developer API key
    @author: Alessandro Tanasi
    @license: GNU Public License version 3
    @contact: alessandro@tanasi.it
    @note: We are using web API and not SOAP API because twisted doesn't support HTTP/1.1 requestes in t.w.client.getPage()
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
        Query Bing using dork ip: to ge a list of domains
        """
        
        # If isn't defined a Bing API Key use another plugin
        if not conf.bingApiKey:
            return
        
        self.job = "%s-%s" % (__name__, ip)
        hd.job(self.job, "starting")
        
        self.hosts = set()
        self.requests = 0
       
        # See http://msdn.microsoft.com/en-us/library/dd251004.aspx
        for offset in range(0,1000,50): 
            query = client.getPage("http://api.search.live.net/xml.aspx?Appid=%s&query=ip:%s&sources=web&web.count=50&web.offset=%s" % (conf.bingApiKey, ip, offset))
            query.addCallback(self.__callSuccess, hd)
            query.addErrback(self.__callFailure, hd)
            
            self.requests = self.requests + 1
        
        hd.job(self.job, "waiting")
    


    def __callFailure(self, failure, hd):
        """
        If a live search run fails
        """
        
        # failure.printTraceback()
        
        # Add found virtual host
        for fqdn in self.hosts:
            hd.notifyHost(fqdn)
            log.debug("Plugin %s added result: %s" % (__name__, fqdn))

        hd.job(self.job, "failure")



    def __callSuccess(self, success, hd):
        """
        If a live search run success
        """

        regexp = re.compile(r'<web:Url>(.*?)</web:Url>')
        
        results = regexp.findall(str(success))
                                 
        # Add new found hosts
        for host in set(results):
            fqdn = urlparse(host).hostname
            self.hosts.add(fqdn)
                
        self.requests = self.requests - 1
        
        # If todo host list is empty we have finished
        if self.requests == 0:
            # Add found virtual host
            for fqdn in self.hosts:
                hd.notifyHost(fqdn)
                log.debug("Plugin %s added result: %s" % (__name__, fqdn))
            
            hd.job(self.job, "done")
  