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


from twisted.names.client import createResolver
from lib.core.configuration import conf


class Client():
    """
    DNS twisted client wrapper
    @license: GNU Public License version 3
    @author: Alessandro Tanasi 
    @contact: alessandro@tanasi.it
    @todo: Add request throttling
    """


    def __init__(self):
        # Try to load DNS server from configuration
        if conf.DNS:
            self.servers = []
            for server in conf.DNS.split(","):
                self.servers.append((server, 53))
        else:
            self.servers = None
        # Call twisted resolver
        self.resolver = createResolver(servers=self.servers)
           
    
    def lookupPointer(self, ip):
        return self.resolver.lookupPointer(ip)
    
    
    def getHostByName(self, host):
        return self.resolver.getHostByName(host)
    
    
    def lookupMailExchange(self, domain):
        return self.resolver.lookupMailExchange(domain)
    
    
    def lookupNameservers(self, domain):
        return self.resolver.lookupNameservers(domain)


client = Client()