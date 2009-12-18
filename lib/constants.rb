module HostMap
  LICENSE = "GPLv3"
  
  #
  # Versioning information
  #
  MAJOR    = 0
  MINOR    = 2
  RELEASE  = ""
  VERSION  = "#{MAJOR}.#{MINOR}#{RELEASE}"
  CODENAME = "prematurata"
  
  #
  # Paths
  #
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  CONFFILENAME = 'hostmap.conf'
  CONFFILE = ROOT + File::SEPARATOR + CONFFILENAME
  PLUGINDIRNAME = 'discovery'
  PLUGINDIR = ROOT + File::SEPARATOR + PLUGINDIRNAME
  DICTIONARYDIRNAME = 'dictionaries'
  DICTDIR = ROOT + File::SEPARATOR + DICTIONARYDIRNAME
  HOSTLISTLITE = 'hostnames-lite.txt'
  DICTLITE = DICTDIR + File::SEPARATOR + HOSTLISTLITE
  HOSTLISTCUSTOM = 'hostnames-custom.txt'
  DICTCUSTOM = DICTDIR + File::SEPARATOR + HOSTLISTCUSTOM
  HOSTLISTFULL = 'hostnames-full.txt'
  DICTFULL = DICTDIR + File::SEPARATOR + HOSTLISTFULL
  LIBDIR = ROOT + File::SEPARATOR + 'lib'
  MTLDFILE = LIBDIR + File::SEPARATOR + 'mtld.txt'
                      
end