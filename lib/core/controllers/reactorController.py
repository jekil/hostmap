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
#    it under the terms of the GNU General Public License a@params tag: types published by
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



from twisted.internet import reactor

import lib.core.outputDeflector as log



"""
Manage Twisted reactor

@author: Alessandro Tanasi <alessandro@tanasi.it>
"""



def start():
    """
    Start Twisted reactor
    """
    
    log.out.debug("Reactor started",  time=True, tag="REACTOR")
    reactor.run()



def stop():
    """
    Stop Twisted reactor
    """
    
    log.out.debug("Reactor stopped",  time=True, tag="REACTOR")
    reactor.stop()
