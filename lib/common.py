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



"""
Common methods
@license: Private licensing
@author: Alessandro Tanasi
@contact: alessandro@tanasi.it
"""



from lib.core.hmException import *



def parseDomain(fqdn):
    """
    Parse a fully qualified domain name and return a domain
    @param fqdn: Full qualified hostname
    @return: Extracted domain name 
    @raise: If unable to parse domain name
    """

    # Check if we already have the domain or we must parse it
    if len(fqdn.split(".")) > 2:
        domain = ".".join(fqdn.split(".")[1:])
    elif len(fqdn.split(".")) == 2:
       domain = fqdn
    else:
        raise hmParserException("Unable to parse domain name %s" % fqdn)

    return domain



def sanitizeFqdn(fqdn):
    """
    Sanitize a fqdn name
    @param fqdn: Value to sanitize
    @return: Value sanitized
    """

    return str(fqdn).lower()
