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



import re
from urlparse import urlparse
from twisted.web import client
from lib.core.outputDeflector import log



class livebyaddress:
    """ 
    Check against microsoft Live
    @author: Alessandro Tanasi
    @license: Private software
    @contact: alessandro@tanasi.it
    @bug: This get only the first page of search results
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
        Query Microsoft Live! using dork ip: to ge a list of domains
        """
        
        self.job = "%s-%s" % (__name__, ip)
        hd.job(self.job, "starting")
        
        # Compose url
        # TODO: search more pages
        url = "http://search.msn.com/results.aspx?q=ip:%s" % ip
        
        # Search
        query = client.getPage(url)
        query.addCallback(self.__callSuccess, hd)
        query.addErrback(self.__callFailure, hd)
        
        hd.job(self.job, "waiting")
    


    def __callFailure(self, failure, hd):
        """
        If a live search run fails
        """
        
        # failure.printTraceback()
        
        hd.job(self.job, "failure")



    def __callSuccess(self, success, hd):
        """
        If a live search run success
        """
        
        # Regexp to catch fqdn
        regexp = "<li><h3><a href=\"(.*?)\" "
        # Cast object, paranoid mode
        page = str(success)
        # Grep
        results = re.findall(regexp, page, re.I | re.M)
        
       # Add new found hosts
        for host in set(results):
            host = urlparse(host).hostname
            hd.notifyHost(host)
            log.debug("Plugin %s added result: %s" % (__name__, host))
        
        hd.job(self.job, "done")
