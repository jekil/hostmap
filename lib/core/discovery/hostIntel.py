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



from lib.common import *
from lib.supadict import supaDict
from lib.core.hmException import hmDupException



class Host():
    """
    This class correlate and aggregate informations that comes from different modules.
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    @bug: Cannot use property, if you access via property error exception aren't raised. Investigate in the use of none in property
    """
    
    
    
    def __init__(self, ip):
        """
        Initialize host intelligence
        @param ip: Host ip address
        """
        
        # Create intelligence dict
        self.infos = supaDict()
        # Target ip address
        self.infos.target = ip
        # Revers resolution hostname
        self.infos.hostname = None
        # Domains of the enurated virtual hosts
        self.infos.domains = []
        # A list of namservers for enumerated domains
        self.infos.nameservers = []
        # A list of fqdn virtual hosts
        self.infos.vhosts = []

    
    
    def getIp(self):
        """
        Getter for target IP address
        @return: Target ip address
        """
        
        return self.infos.target

    ip = property(getIp, None)
    
 

    def setHostname(self, fqdn):
        """
        Set the hostname of target ip address, set via reverse dns lookup
        @param fqdn: Full qualified hostname
        """
        
        fqdn = sanitizeFqdn(fqdn)
        self.infos.hostname = fqdn



    def getHostname(self):
        """
        Return target's hostname due reverse dns lookup
        @return: Target hostname
        """
        return self.infos.hostname       

    hostname = property(getHostname, setHostname)


    
    def setDomain(self, domain):
        """
        Add a new domain from a enumeration plugin        
        @params domain: Domain name
        @raise hmDupException: If try to add a duplicate
        """
        
        domain = sanitizeFqdn(domain)
        
        # Check if domain is already been enumerated
        if domain in self.infos.domains:
            raise hmDupException("Duplicated domain")
        
        # Add a new domain
        self.infos.domains.append(domain)
        
    domain = property(None, setDomain)
    

    
    def setNameserver(self, nameserver):
        """
        Add a new NS from a enumeration plugin    
        @params nameserver: Set nameserver
        @raise hmDupException: If try to add a duplicate
        """
        
        nameserver = sanitizeFqdn(nameserver)
        
        # Check if NS is already been enumerated
        if nameserver in self.infos.nameservers:
            raise hmDupException("Duplicated nameserver")
                
        # Check if domain is null of empty
        if nameserver is None or nameserver == "":
            raise hmDupException("Null nameserver")
        
        # Add new NS
        self.infos.nameservers.append(str(nameserver)) 
        
    nameserver = property(None, setNameserver)

    

    def setHost(self, fqdn):
        """
        Add a new host from a enumeration plugin
        @params fqdn: Fully qualified domain name of enumerated virtual host
        @raise hmDupException: If try to add a duplicate
        """
        
        fqdn = sanitizeFqdn(fqdn)
        
        # Check if host is already in enumerated host list
        if fqdn in self.infos.vhosts: 
            raise hmDupException("Duplicated host")
        
        # Check if host is null of empty
        if fqdn is None or fqdn == "": 
            raise hmDupException("Null host")
        
        # Add found host
        self.infos.vhosts.append(fqdn)

    host = property(None, setHost)
    
    
    
    def results(self):
        """
        Retrive all data
        @return: Host data
        """
        
        return self.infos