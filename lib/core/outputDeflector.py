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



from time import strftime
import lib.core.configuration as configuration



class outputDirector:
    """
    Manage output.

    @author: Alessandro Tanasi <alessandro@tanasi.it>
    """
    
    
    
    def __init__(self):
        # List of output handlers
        self.outputPlugins = {}



    def __message(self,  text, cr = True,  time = False,  tag = None):
        """
        Format and write a generic message
        
        @params text: message text
        @params cr: presence of new line
        @params time: print timestamp
        @params tag: type
        """
    
        # Add a tag (example [ENGINE] yadda yadda)
        if tag:
            text = "[%s] %s" % (tag,  text)
        # Add timestamp
        if time:
            text = "[%s] %s" % (strftime("%X"),  text)
        
        # Encode message in unicode
        text = unicode(text, errors='replace')
        
        #TODO:
        print text
        
        

    def info(self,  text, cr = True,  time = False,  tag = None):
        """
        A info message to all output plugins
        
        @params text: message text
        @params cr: presence of new line
        @params time: print timestamp
        @params tag: type
        """
        
        self.__message(text, cr,  time,  tag)


    
    def debug(self,  text, cr = True,  time = False,  tag = None):
        """
        A debug message to all output plugins
        
        @params text: message text
        @params cr: presence of new line
        @params time: print timestamp
        @params tag: type
        """
        
        if  configuration.conf.Verbose == True:
            self.__message(text, cr,  time,  tag)



    def error(self,  text, cr = True,  time = False,  tag = None):
        """
        An error message to all output plugins
        
        @params text: message text
        @params cr: presence of new line
        @params time: print timestamp
        @params tag: type
        """
        
        self.__message(text, cr,  time,  tag)



    def fatal(self,  text, cr = True,  time = False,  tag = None):
        """
        A fatal message to all output plugins, the program must be aborted
        
        @params text: message text
        @params cr: presence of new line
        @params time: print timestamp
        @params tag: type
        """
        
        self.__message(text, cr,  time,  tag)
        # TODO:abort
        # OH! WTF?! A fatality?!



# This class must be a Singleton. There is only one output handler.
out = outputDirector()
