PlugMan.define :plugin_data do
  author "Aaron"
  version "1.0.0"
  extends
  requires []
  extension_points []
  params()
  
  def data()
    ret = []
    
    # loop all the plugins and find info about them
    PlugMan.registered_plugins.sort do |a,b|
      a[0].to_s <=> b[0].to_s
    end.each do |name, obj|
      item = { 
        :name => name.to_s,
        :version => obj.version,
        :state => obj.state,
        :extension_points => [],
        :requires => [] + obj.requires.flatten
      }
      
      # add the extensions offered by the plugin to the :requires list
      item[:requires] << obj.extends.collect do |nm, ext|
        "#{nm.to_s}(#{ext.join(', ')})"
      end if obj.extends
      
      # loop the plugin's extension points and find out what other plugins are
      # connected
      obj.extension_points.each do |extpt|
        conn = []
        PlugMan.extensions(name, extpt).each do |pl|
          conn << pl.name.to_s #if extpt == pl.extends
        end

        item[:extension_points] << {
          :name => extpt.to_s,
          :connections => conn
        }
      end if obj.extension_points 
      ret << item
    end
    ret
  end
end
