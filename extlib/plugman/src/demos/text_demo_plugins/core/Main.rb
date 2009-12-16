PlugMan.define :main do
  author "Aaron"
  version "1.0.0"
  extends(:root => [:root])
  requires []
  extension_points [:transform]
  params()

  #
  # Uses plugins to perform string transformations
  #
  def do_xforms(input)

    puts
    puts "Input text is #{input.inspect}\n"
    
    #
    # run the text processor plugins
    #
    @logger.debug { "About to do string xform processing" }
    PlugMan.extensions(:main, :transform).each do |plugin|
      out = plugin.xform(input)
      puts "\nPlugin:\t#{plugin.name.inspect}\nDesc:\t#{plugin.params[:description]}\nOutput:\t#{out}"
    end
    puts
  end
  
  #
  # prints information about plugins to the screen
  #
  def plugin_info()
    puts "Registered plugins"
    puts
    
    # loop all the plugins in the system, sorting before we loop
    PlugMan.registered_plugins.sort do |a,b|
      a.to_s <=> b.to_s
    end.each do |k,v|
      # printout plugin information
      puts "Name:\t\t#{k.inspect}\nAuthor:\t\t#{v.author}\nVersion:\t#{v.version}"
      puts "Requires:\t#{PlugMan.depends_on(k).sort{|a,b| a.to_s <=> b.to_s}.join(', ')}"
      
      # gather the plugins connected to the plugin's extension points
      str = ""
      v.extension_points.each do |extpt|
        conn = []
        PlugMan.extensions(k, extpt).each do |pl|
          conn << pl.name.to_s
        end
        str = "#{extpt.inspect}(#{conn.join(", ")})"
      end if v.extension_points
      
      puts "Ext points:\t#{str}"
      puts
    end
  end
end
