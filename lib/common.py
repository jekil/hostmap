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



from lib.core.controllers.hmException import *



def parseDomain(fqdn):
    """
    Parse a fully qualified domain name and return a domain
    @param fqdn: full qualified hostname
    @return: extracted domain name 
    """

    # Check if we already have the domain or we must parse it
    if len(fqdn.split(".")) > 2:
        domain = ".".join(fqdn.split(".")[1:])
    elif len(fqdn.split(".")) == 2:
       domain = fqdn
    else:
        raise hmParserException("Unable to parse domain name %s" % fqdn)

    return domain
