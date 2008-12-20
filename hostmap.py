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



import traceback
from lib.settings import VERSION, CODENAME
from lib.core.hmException import *
import lib.core.optionParser as options
from lib.output.outputDeflector import log
import lib.core.dependences as deps
import lib.core.controllers.engineController as engine



def main():
    """ 
    Start of the hostmap world. Main workflow
    """
    
    # Show banner, credits and stuff
    showCredits()
    
    try:       
        # Parse command line
        options.parseArgs()
        
        # Preventive dependency check
        deps.check()
        
        # Start hostmapping
        engine.en.start()
        
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
        
    except Exception:
        print
        print "Unhandled exception. Please report this bug sending an email to alessandro@tanasi.it attaching the following text:"
        traceback.print_exc()



def showCredits():
    """
    Show banner and credits
    """
    
    log.info("hostmap version %s codename %s" % (VERSION, CODENAME))
    log.info("Coded by Alessandro `jekil` Tanasi <alessandro@tanasi.it>")
    log.info("")
    


# Main
if __name__ == "__main__":
    main()
