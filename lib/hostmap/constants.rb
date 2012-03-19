module Hostmap
  LICENSE = "GPLv3"
  
  #
  # Versioning information
  #
  MAJOR    = 0
  MINOR    = 3
  RELEASE  = ""
  VERSION  = "#{MAJOR}.#{MINOR}#{RELEASE}"
  CODENAME = "development"
  
  #
  # Paths
  #
  ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  CONFFILENAME = 'hostmap.conf'
  CONFFILE = ROOT + File::SEPARATOR + CONFFILENAME
  LIBDIR = File.join(ROOT, 'lib', 'hostmap')
  PLUGINDIRNAME = 'discovery'
  PLUGINDIR = ROOT + File::SEPARATOR + PLUGINDIRNAME
  DICTIONARYDIRNAME = 'dictionaries'
  DICTDIR = LIBDIR + File::SEPARATOR + DICTIONARYDIRNAME
  HOSTLISTLITE = 'hostnames-lite.txt'
  DICTLITE = DICTDIR + File::SEPARATOR + HOSTLISTLITE
  HOSTLISTCUSTOM = 'hostnames-custom.txt'
  DICTCUSTOM = DICTDIR + File::SEPARATOR + HOSTLISTCUSTOM
  HOSTLISTFULL = 'hostnames-big.txt'
  DICTFULL = DICTDIR + File::SEPARATOR + HOSTLISTFULL
  MTLDFILE = LIBDIR + File::SEPARATOR + 'mtld.txt'
  TLDFILE = PLUGINDIR + File::SEPARATOR + 'dns' + File::SEPARATOR + 'tld.txt'
end