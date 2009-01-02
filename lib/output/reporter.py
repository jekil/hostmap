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



from lib.output.outputDeflector import log
from lib.core.configuration import conf



class Report():
    """
    Report results
    @license: Private licensing
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """
    
    
    def __init__(self, results):
        self.res = results
        self.report()
        
        
    
    def report(self):
        """
        Show results
        """

        # Set output vars
        if conf.Paranoid:
            prob = "(confirmed)"
        else:
            prob = "(probable)"

        # Print out report
        log.info("")
        log.info("Results for %s" % self.res.target)
        log.info("Hostname: %s" % self.res.hostname)
        log.info("Served by nameservers (probable): %s" % " ".join(self.res.nameservers))
        log.info("Belongs to domains %s: %s" % (prob, " ".join(self.res.domains)))
        if self.res.vhosts:
            log.info("Aliases enumerated %s:" % prob)
            for h in self.res.vhosts:
                log.info("%s" % h)
        else:
            log.info("No aliases enumerated")
        