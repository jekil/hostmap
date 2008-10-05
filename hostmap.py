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
