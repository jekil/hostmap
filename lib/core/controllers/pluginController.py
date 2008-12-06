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



import os
import sys
from lib.settings import *
from lib.output.outputDeflector import log
from lib.core.hmException import *



class plugin:
    """ 
    Plugins engine that handle an event based host discovery
    @author:       Alessandro Tanasi
    @license:      Private software
    @contact:      alessandro@tanasi.it
    """



    def __init__(self,  debug = False):
        """
        Initializes variables and does preventive checks
        """
        
        # Tag used in all output messages
        self.tag = "PLUGIN"
        
        # Host discovery debug mode
        self.debug = debug
        
        # Directory of plugins
        self.pluginDir = PLUGINDIR
        
        # Preventive check for plugin directory
        self.precheck()
        
        # Plugin dependencies array
        self.pluginsByIp = []
        self.pluginsByDomain = []
        self.pluginsByNameserver = []
        self.pluginsByHostname = []
        
        # Populate dependencies
        self.buildDeps()



    def precheck(self):
        """
        Preventive check for plugin directory existance
        @raise hmFileException: If plugin directory is not found
        """
        
        if os.path.exists(self.pluginDir):
            if self.debug: log.debug("Plugin directory exist", time=True, tag=self.tag)
        else:
            if self.debug: log.debug("Plugin directory not exist", time=True, tag=self.tag)
            raise hmFileException("Plugin directory %s not found", self.pluginDir)
        
        
        
    def getPlugins(self):
        """
        Scan plugins directory and make a list of available plugins
        @returns: Array with list of plugins
        @raise hmFileException: If cannot found any plugin
        """
        
        # List of plugins in category.plugin syntax, useful for importing
        plugins = []
        
        # Get categorie's names
        dirList = [ f for f in os.listdir(self.pluginDir) ] 
        
        # Remove some stuff
        try:
            dirList.remove ("__init__.py")
            dirList.remove ("__init__.pyc")
            dirList.remove (".svn")
        except ValueError:
            pass
        
        # Get file's names
        for dir in dirList:
            for file in os.listdir(self.pluginDir + os.path.sep + dir):
                # Skip some stuff
                if file == ".svn" or file == "__init__.py":
                    continue
                
                # Get plugins name
                if os.path.splitext(file)[1] == ".py":
                    plugin = self.pluginDir + "." + dir + "." + os.path.splitext(file)[0]
                    plugins.append(plugin)
                    if self.debug: log.debug("Found plugin: %s" % plugin, time=True, tag=self.tag)
        
        if plugins is None: raise hmFileException("No plugins found")
        return plugins



    def factory(self, ModuleName, *args):
        """
        Plugin factory, istantiate a plugin and return the handler
        @todo: Add docstring
        """
        
        __import__(ModuleName)
        aModule = sys.modules[ModuleName]
        className = ModuleName.split('.')[len(ModuleName.split('.'))-1]
        aClass = getattr( aModule , className )
        return apply(aClass, args)



    def buildDeps(self):
        """
        Build plugin's dependencies
        """
        
        # Get plugin list
        for plugin in self.getPlugins():
            try:
                # Istantiate a the plugin
                pl = self.factory(plugin)
                
                # Build dependencies array
                deps = pl.require()
            except:
                # TODO: remove plugin from list and log the error
                continue
            
            # Trivial case..
            if deps == "ip":  
                self.pluginsByIp.append(plugin)
                if self.debug: log.debug("Plugin %s added to ip queue" % plugin, time=True, tag=self.tag)
                
            if deps == "domain":  
                self.pluginsByDomain.append(plugin)
                if self.debug: log.debug("Plugin %s added to domain queue" % plugin, time=True, tag=self.tag)
                
            if deps == "nameserver":  
                self.pluginsByNameserver.append(plugin)
                if self.debug: log.debug("Plugin %s added to nameserver queue" % plugin, time=True, tag=self.tag)
                
            if deps == "hostname":  
                self.pluginsByHostname.append(plugin)
                if self.debug: log.debug("Plugin %s added to hostname queue" % plugin, time=True,  tag=self.tag)



    def runByIp(self, hd, ip):
        """
        Run all plugins that depends from ip addresses
        """
        
        for plugin in self.pluginsByIp:
            try:
                # Istantiate a the plugin
                pl = self.factory(plugin)
                    
                # Run
                pl.run(hd, ip)
            except Exception, e:
                log.fatal("Plugin %s get an error. Unhandled exception: %s" % (plugin, e), time=True, tag=self.tag)



    def runByDomain(self, hd, domain):
        """
        Run all plugins that depends from domain
        """
        
        for plugin in self.pluginsByDomain:
            try:
                # Istantiate a the plugin
                pl = self.factory(plugin)
                    
                # Run
                pl.run(hd, domain)
            except Exception,  e:
                log.fatal("Plugin %s get an error. Unhandled exception: %s" % (plugin, e), time=True, tag=self.tag)



    def runByNameserver(self, hd, nameserver):
        """
        Run all plugins that depends from nameserver
        """
        
        for plugin in self.pluginsByNameserver:
            try:
                # Istantiate a the plugin
                pl = self.factory(plugin)
                    
                # Run
                pl.run(hd, nameserver)
            except Exception, e:
                log.fatal("Plugin %s get an error. Unhandled exception: %s" % (plugin, e), time=True, tag=self.tag)



    def runByHostname(self, hd, hostname):
        """
        Run all plugins that depends from ip hostname
        """
        
        for plugin in self.pluginsByHostname:
            try:
                # Istantiate a the plugin
                pl = self.factory(plugin)
                    
                # Run
                pl.run(hd, hostname)
            except Exception,  e:
                log.error("Plugin %s get an error. Unhandled exception: %s" % (plugin, e), time=True, tag=self.tag)
