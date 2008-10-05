#!/usr/bin/env python
#
#   hostmap
#   http://hostmap.sourceforge.net/
#
#   Author:
#    Alessandro `jekil` Tanasi <alessandro@tanasi.it>
#
#   License:
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
# Notes:
#



from common import *
from lib.supadict import supaDict



class Host:
    """
    This class correlate and aggregate informations that comes from different modules.
    
    @Author: Alessandro Tanasi
    """
    
    
    
    def __init__(self, engine, ip):
        """
        Initialize host intelligence
        """
        
        # Create intelligence dict
        self.infos = supaDict()
        # Target ip address
        self.infos.target = ip
        # Revers resolution hostname)
        self.__hostname = None
        # Domains of the enurated virtual hosts
        self.infos.domains = []
        # A list of namservers for enumerated domains
        self.infos.nameservers = []
        # A list of fqdn virtual hosts
        self.infos.vhosts = []
        # Webservers
        self.__webservers = []
        # Reference to engine
        self.__engine = engine

    
    
    # __ip
    def getIp(self):
        """
        Getter for target IP address
        """
        
        return self.intel.target

 
 
    # __hostname

    def setHostname(self, fqdn):
        """
        """
        # Sanitize
        fqdn = fqdn.lower()
        
        self.__hostname = fqdn
        
        # Add new found virtual host
        self.__hosts.append(fqdn)
        
        # Get domian name and add to new domains found
        self.setDomain(parseDomain(fqdn))

    def getHostname(self):
        return self.__hostname       



    # __domain
    
    def addDomain(self, domain):
        """
        Add a new domain from a enumeration plugin
        
        @params domain: domain name
        """
        
        # Check if domain is already been enumerated
        # TODO: Refactor this shit!
        for dom in self.infos.domains:
            if domain == dom:
                return False
        
        # Sanitize
        domain = domain.lower()
        
        # Add a new domain
        self.infos.domains.append(domain)
        return True
    

    
    def addNameserver(self, nameserver):
        """
        Add a new NS from a enumeration plugin
        
        @params nameserver: nameserver
        """
        
        # Check if NS is already been enumerated
        # TODO: Refactor this shit!
        for ns in self.infos.nameservers:
            if nameserver == ns:
                return False
                
        # Check if domain is null of empty
        if ns is None or ns == "":
            return False
    
        # Sanitize
        nameserver = nameserver.lower()
        
        # Add new NS
        self.infos.nameservers.append(str(nameserver))
        return True   

    

    def addHost(self, fqdn):
        """
        Add a new host from a enumeration plugin
        
        @params fqdn: fully qualified domain name of enumerated virtual host
        """
        
        # Check if host is already in enumerated host list
        for host in self.infos.vhosts:
            if fqdn == host:
                return False
        
        # Check if host is null of empty
        if fqdn is None or fqdn == "":
            return False
            
        # Sanitize
        fqdn = fqdn.lower()
        
        # TODO:
        # Be paranoid, each result hostname is resolved to check consistency
        #if not self.conf.Paranoid:
        #   ip = self.d.getHostbyName(fqdn)
        #    if ip == self.target.getIp():
        #       self.target.setResult(fqdn)
        #else:
        #    self.target.setResult(fqdn)
        self.infos.vhosts.append(fqdn)
        return True

    
    
    def setFoundHostbyIp(self, fqdn, ip):
        """
        Add a result from a enumeration plugin 
        """
        
        # Preventive check)
        if ip != self.intel['Target IP']:
            return
        
        # Add host
        self.setFoundHost(fqdn)

    
    
    def setResult(self,  fqdn):
        """
        Add new enumerated hostname
        """
        
        # Sanitize
        fqdn = fqdn.lower()
        
        # Add found host
        self.__hosts.append(str(fqdn))
        # Add found domain
        self.setDomain(parseDomain(fqdn))
        
        
    # TODO:
    def setWebserver(self, fqdn):
        """
        A web server has been found
        """
        
        # Check if host is already in enumerated web host list
        for host in self.__webservers:
            if fqdn == host:
                return
        
        # Sanitize
        fqdn = fqdn.lower()
        
        # Add found web server
        self.__webservers.append(str(fqdn))
        
        
    # TODO:
    def setIpHomePage(self,  page):
        """
        Setter for home page of a web server by ip address
        """
        
        self.intel['Web Server.IP Page'] = page
        
        
    # TODO:
    def getIpHomePage(self):
        """
        Getter for home page of a web server by ip address
        """
        
        return self.intel['Web Server.IP Page']
        
        
        
    def status(self):
        """
        """
        
        print self.infos
        return
        
        print "Target ip: %s" % self.intel['Target IP']
        print "Target domain: %s" % self.__domains
        
        print "Hostname: %s" % self.__hostname

        print "NS: %s" % self.__nameservers
        print "RESULTS: %s"  % self.__hosts
        print "Web server: %s" % self.__webservers
