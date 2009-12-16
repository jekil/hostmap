PlugMan.define :core do
  author "Aaron"
  version "1.0.0"
  extends(:root => [:root])
  requires []
  extension_points [:app_init, :app_start, :app_run, :app_stop, :app_exit]
  params()
  
  def launch()
    
    # run the init plugins
    @logger.debug { "About to do app_init processing" }
    PlugMan.extensions(:core, :app_init).each do |plugin|
      plugin.app_init()
    end

    # run the start plugins
    @logger.debug { "About to do app_start processing" }
    PlugMan.extensions(:core, :app_start).each do |plugin|
      plugin.app_start()
    end
    
    # run the run plugins
    @logger.debug { "About to do app_run processing" }
    PlugMan.extensions(:core, :app_run).each do |plugin|
      plugin.app_run()
    end

    # run the stop plugins
    @logger.debug { "About to do app_stop processing" }
    PlugMan.extensions(:core, :app_stop).each do |plugin|
      plugin.app_stop()
    end

    # run the exitplugins
    @logger.debug { "About to do app_exit processing" }
    PlugMan.extensions(:core, :app_exit).each do |plugin|
      plugin.app_exit()
    end

  end
end
