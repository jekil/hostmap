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



from time import strftime
from lib.core.configuration import *



class outputDirector:
    """
    Manage output and logging
    @author:       Alessandro Tanasi
    @license:      Private software
    @contact:      alessandro@tanasi.it
    """
    
    
    
    def __init__(self):
        # List of output handlers
        self.outputPlugins = {}



    def __message(self, text, cr = True, time = False, tag = None):
        """
        Format and write a generic message      
        @params text: message text
        @params cr: presence of new line
        @params time: print timestamp
        @params tag: type
        """
    
        # Add a tag (example [ENGINE] yadda yadda)
        if tag: text = "[%s] %s" % (tag,  text)
        # Add timestamp
        if time: text = "[%s] %s" % (strftime("%X"),  text)
        
        # Encode message in unicode
        text = unicode(text, errors='replace')
        
        #TODO:
        print text
        
        

    def info(self, text, cr = True, time = False, tag = None):
        """
        A info message to all output plugins
        @params text: message text
        @params cr: presence of new line
        @params time: print timestamp
        @params tag: type
        """
        
        self.__message(text, cr, time, tag)


    
    def debug(self, text, cr = True, time = False, tag = None):
        """
        A debug message to all output plugins
        @params text: message text
        @params cr: presence of new line
        @params time: print timestamp
        @params tag: type
        """
        
        if conf.Verbose == True:
            self.__message(text, cr, time, tag)



    def error(self, text, cr = True, time = False, tag = None):
        """
        An error message to all output plugins
        @params text: message text
        @params cr: presence of new line
        @params time: print timestamp
        @params tag: type
        """
        
        self.__message(text, cr, time, tag)



    def fatal(self, text, cr = True, time = False, tag = None):
        """
        A fatal message to all output plugins, the program must be aborted
        @params text: message text
        @params cr: presence of new line
        @params time: print timestamp
        @params tag: type
        """
        
        self.__message(text, cr,  time,  tag)
        # TODO:abort?
        # OH! WTF?! A fatality?!



# This class must be a Singleton. There is only one output handler.
out = outputDirector()
# TODO: remove
log = out