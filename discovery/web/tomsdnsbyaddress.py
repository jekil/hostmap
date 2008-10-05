import re
from twisted.web import client

import lib.core.outputDeflector as log
import lib.core.configuration as configuration



class tomsdnsbyaddress:



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
        Query Tomdns using dork ip: to ge a list of domains
        """
    
        self.job = "%s-%s" % (__name__,  ip)
        hd.job(self.job, "starting")
        
        # Compose url
        url = "http://www.tomdns.net/get_hostonip.php?target=%s" % ip
        
        # Search
        query = client.getPage(url)
        query.addCallback(self.__callSuccess, hd)
        query.addErrback(self.__callFailure, hd)
        
        hd.job(self.job, "waiting")
    


    def __callFailure(self, failure, hd):
        """
        If a Tomdns search run fails
        """
        
        failure.printTraceback()
        
        hd.job(self.job, "failure")


    def __callSuccess(self, success, hd):
        """
        If a Tomdns run success
        """
        
        # TODO: test this and redo the parsing regexp
        # Regexp to catch fqdn
        regexp = "\076(.*)\n\074"
        # Cast object, paranoid mode
        page = str(success)

        # Grep
        results = re.findall(regexp, page, re.I | re.M)
        
        # Add new found hosts
        for host in set(results):
            hd.notifyHost(host)
            log.out.debug("Plugin %s added result: %s" % (__name__,  host))
        
        hd.job(self.job, "done")
