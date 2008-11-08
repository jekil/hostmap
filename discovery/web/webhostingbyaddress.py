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

import lib.core.outputDeflector as log
import lib.core.configuration as configuration



class webhostingbyaddress:



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



    def run(self, hd,  ip):
        """
        Query Webhosting using dork ip: to ge a list of domains
        """
    
        self.job = "%s-%s" % (__name__,  ip)
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
        
        failure.printTraceback()
        
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
        
        hd.job(self.job, "done")
