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
from twisted.internet.protocol import ClientFactory
from twisted.protocols.basic import LineReceiver
from twisted.internet import ssl, reactor
from lib.output.outputDeflector import log
from lib.settings import HTTP_PORTS
try:
    from OpenSSL import SSL
except:
    log.error("Python-openSSL not found. Plugin %s cannot run." % __name__)


class sslcertbyip:
    """ 
    Check if target ip runs a web server
    @author: Alessandro Tanasi
    @license: Private software
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
        return "ip"



    def run(self, hd, ip):
        """
        Check all ports to SSL enabled
        """

        # Negotiate SSL protocol
        for port in HTTP_PORTS:
            job = "%s-%s-%i" % (__name__, ip, port)
            hd.job(job, "starting")
            reactor.connectSSL(ip, port, FakeClientFactory(hd, job), ClientContextFactory(hd, job))
            hd.job(job, "waiting")
   
   

class ClientContextFactory(ssl.ClientContextFactory):
    """
    An SSL conncetion factory
    """

    def __init__(self, hd, job):
        self.hd = hd
        self.job = job
        
    def _verify(self, connection, x509, errnum, errdepth, ok):
        host = str(x509.get_issuer().CN)
        
        if host:
            self.hd.notifyHost(host)
            log.debug("Plugin %s added result: %s" % (__name__, host))
            
        return ok

    def getContext(self):
        ctx = ssl.ClientContextFactory.getContext(self)
        ctx.set_verify(SSL.VERIFY_PEER, self._verify)
        return ctx



class FakeClient(LineReceiver):
    """
    A fake protocol
    """

    def connectionMade(self):
        pass

    def connectionLost(self, reason):
        pass

    def lineReceived(self, line):
        """
        Get X.509 certificate
        """
        x509 = self.transport.getPeerCertificate()
        self.transport.loseConnection()



class FakeClientFactory(ClientFactory):
    """
    A fake client factory
    """
    
    protocol = FakeClient
    
    def __init__(self, hd, job):
        self.hd = hd
        self.job = job

    def clientConnectionFailed(self, connector, reason):
        self.hd.job(self.job, "failure")
        pass

    def clientConnectionLost(self, connector, reason):
        self.hd.job(self.job, "done")
        pass
