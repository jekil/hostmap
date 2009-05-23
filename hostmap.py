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
#    along with hostmap.  If not, see <http://www.gnu.org/licenses/>.



import traceback
from lib.settings import VERSION, CODENAME
from lib.core.hmException import *
import lib.core.optionParser as options
from lib.output.logger import log
import lib.core.dependences as deps
from lib.core.controllers.engineController import Engine



class HostMap:
    """
    Hostmap
    @license: GNU Public License version 3
    @author: Alessandro Tanasi
    @contact: alessandro@tanasi.it
    """



    def start(self):
        """ 
        Start of the hostmap world. Main workflow
        """
        
        # Show banner, credits and stuff
        self.credits()
        
        try:       
            # Parse command line
            options.parseArgs()
            
            # Preventive dependency check
            deps.check()
            
            # Start hostmapping
            Engine().start()
            
        except hmImportException, e:
            print
            print "Execution aborted, missing dependencies!"
            print e
            
        except hmOptionException, e:
            print
            print "Execution aborted, missing option value!"
            print e
            
        except hmFileException, e:
            print 
            print "Execution aborted, file or directory not found!"
            print e
            
        except KeyboardInterrupt:
            print "Execution aborted"
            
        except Exception:
            print
            print "Unhandled exception. Please report this bug sending an email to alessandro@tanasi.it attaching the following text:"
            traceback.print_exc()



    def credits(self):
        """
        Show banner and credits
        """
        
        log.info("hostmap %s codename %s" % (VERSION, CODENAME))
        log.info("Coded by Alessandro `jekil` Tanasi <alessandro@tanasi.it>")
        log.info("")
    


# Main
if __name__ == "__main__":
    HostMap().start()
