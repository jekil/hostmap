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
from twisted.web import client
from lib.output.outputDeflector import log



class netcraftbydomain:
    """ 
    Check against netcraft
    @author: Alessandro Tanasi
    @license: Private software
    @contact: alessandro@tanasi.it
    @todo: add suppport to multiple pages
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
        Query netcraft
        """
    
        self.job = "%s-%s" % (__name__, domain)
        hd.job(self.job, "starting")
        
        # Compose url
        url = "http://searchdns.netcraft.com/?restriction=site+ends+with&host=%s" % domain

        # Search
        query = client.getPage(url)
        query.addCallback(self.__callSuccess, hd)
        query.addErrback(self.__callFailure, hd)
        
        hd.job(self.job, "waiting")
    


    def __callFailure(self, failure, hd):
        """
        If search run fails
        """
        
        # failure.printTraceback()
        
        hd.job(self.job, "failure")


    def __callSuccess(self, success, hd):
        """
        If search run success
        """
        
        # Regexp to catch fqdn
        regexp = "uptime.netcraft.com/up/graph/\?host=(.*?)\">"
 
        # Cast object, paranoid mode
        page = str(success)

        # Grep
        results = re.findall(regexp, page, re.I | re.M)

        # Add new found hosts
        for host in set(results):
            hd.notifyHost(host)
            log.debug("Plugin %s added result: %s" % (__name__, host))
        
        hd.job(self.job, "done")
