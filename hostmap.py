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




from lib.settings import *
import lib.core.optionParser as options
import lib.core.outputDeflector as log
import lib.core.dependences as deps
import lib.core.controllers.engineController as engine



def main():
    """ 
    Start of the hostmap world
    """
    
    # Show banner, credits and stuff
    showCredits()
    
    # Parse command line
    options.parseArgs()
    
    # Preventive dependency check
    deps.check()
    
    # Start hostmapping
    engine.en.start()



def showCredits():
    """
    Show banner and credits
    """
    
    log.out.info("hostmap version %s codename %s" % (VERSION, CODENAME))
    log.out.info("Coded by Alessandro `jekil` Tanasi <alessandro@tanasi.it>")
    
    

# Main
if __name__ == "__main__":
    main()
