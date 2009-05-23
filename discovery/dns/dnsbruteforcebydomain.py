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


import socket
from twisted.names import client
from lib.output.logger import log
from lib.core.configuration import conf
import lib.settings as settings


class dnsbruteforcebydomain:
    """ 
    DNS bruteforce check
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
        Start DNS hostnames brute forcing
        """
        # Configuration check
        if not conf.DNSBruteforce:
            log.debug("Skipping DNS bruteforce because it is disabled from command line")
            return
        if conf.OnlyPassive: 
            log.debug("Skipping DNS bruteforce because it is enabled only passive checks")
            return
        
        self.job = "%s-%s" % (__name__, domain)
        hd.job(self.job, "starting")
        
        # False positives or wildcard domain preventive check with random query
        for test in ["antani456", "t4p1occo", "evvivalafocaechilacosa"]:
            # Enqueue host
            fqdn = "%s.%s" % (test, domain)
            # TODO: Use twisted here
            try:
                ip = socket.gethostbyname(fqdn)
            # This exception is raised when a fqdn doesn't exist. 
            # socket.gaierror: (-5, 'No address associated with hostname')
            except socket.gaierror:
                continue
            if conf.Target == ip:
                log.warn("Detected a wildward domain: %s" % fqdn.split(".")[1:])
                hd.job(self.job, "done")
                return
        
        # Load brute force names list
        if conf.DNSBruteforceLevel == "lite":
            hostsPath = settings.HOSTLISTLITE
        elif conf.DNSBruteforceLevel == "custom":
            hostsPath = settings.HOSTLISTCUSTOM
        elif conf.DNSBruteforceLevel == "full":
            hostsPath = settings.HOSTLISTFULL
        else:
            # TODO: raise exception
            hostsPath = settings.HOSTLISTLITE
        
        # Local variables
        self.hostDict = {}
        self.hosts = []
        
        # Load the brute force txt file only one time to prevent "too many open files" errors
        if not conf.DNSBruteforceDict: 
            conf.DNSBruteforceDict = file(hostsPath).read()
            
        # Brute force    
        for host in conf.DNSBruteforceDict.split("\n"):
            # Skip comments
            if host.startswith("#"):
                continue
            # Sanitize
            host = host.replace("\n","").replace("\r","")
            # Compose fqdn
            fqdn = "%s.%s" % (host, domain)
            # Enqueue host
            self.hosts.append(fqdn)
            # Add to dict
            self.hostDict[fqdn] = None
            # Resolve
            query = client.getHostByName(fqdn)
            query.addCallback(self.__callSuccess, hd, fqdn)
            query.addErrback(self.__callFailure, hd, fqdn)
            
        hd.job(self.job, "waiting")
        
        # This piece of software is coded the night between 24 and 25 december, when i came back to home
        # drunk. A pleasure to Glen Grant.
        
    
    def __callFailure(self, failure, hd, fqdn):
        """
        If a brute force run fails
        """
        # Remove host form todo host list
        self.hosts.remove(fqdn)
        
        # If todo host list is empty we have finished
        if len(self.hosts) == 0:
            # NOTE: This plugin cannot return a failure status because if only one query fails all plugin run is marked as failed
            hd.job(self.job, "done")


    def __callSuccess(self, success, hd, fqdn):
        """
        If a brute force run success
        """
        # Check if we found a new virtual host if ip address of brute forced host is the same of target host
        if conf.Target == str(success):
            # Add found virtual host
            hd.notifyHost(fqdn)
            log.debug("Plugin %s added result: %s" % (__name__, fqdn))
        
        # Remove host form todo host list
        self.hosts.remove(fqdn)
        
        # If todo host list is empty we have finished
        if len(self.hosts) == 0:
            hd.job(self.job, "done")
            