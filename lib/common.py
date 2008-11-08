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



def parseDomain(fqdn):
    """
    Parse a fully qualified domain name and return a domain
    """

    # Check if we already have the domain or we must parse it
    if len(fqdn.split(".")) > 2:
        domain = ".".join(fqdn.split(".")[1:])
    else:
       domain = fqdn

    return domain
