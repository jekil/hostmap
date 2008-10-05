import re
from twisted.web import client

import lib.core.outputDeflector as log
import lib.core.configuration as configuration



class livebyaddress:



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
        Query Microsoft Live! using dork ip: to ge a list of domains
        """
        
        self.job = "%s-%s" % (__name__,  ip)
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
        
        failure.printTraceback()
        
        hd.job(self.job, "failure")



    def __callSuccess(self, success, hd):
        """
        If a live search run success
        """
        
        # Regexp to catch fqdn
        regexp = "class=\"dispUrl\">([^\s<>(),;/\'\"]+)"
        # Cast object, paranoid mode
        page = str(success)
        # Grep
        results = re.findall(regexp, page, re.I | re.M)
        
       # Add new found hosts
        for host in set(results):
            hd.notifyHost(host)
            log.out.debug("Plugin %s added result: %s" % (__name__,  host))
        
        hd.job(self.job, "done")
