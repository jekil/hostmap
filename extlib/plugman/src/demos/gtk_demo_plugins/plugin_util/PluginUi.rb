PlugMan.define :plugin_ui do
  author "Aaron"
  version "1.0.0"
  extends
  requires [:plugin_data]
  extension_points [:work_area]
  params()
  
  def start()
    @box = Gtk::VBox.new
    @table
    true
  end
  
  def make_label(str)
    xpad = 10
    xalign = 0.0
    label = Gtk::Label.new
    label.set_markup(str)
    label.xalign = xalign
    label.xpad = xpad
    label
  end
  
  def display()    
    data = get_data()
    @box.each do |child|
      @box.remove(child)  # empty the box
    end
        
    @table = Gtk::Table.new(data.size, 7, false)
    
    # display a heading row
    ii = 0
    label = make_label("<b>Name</b>")
    @table.attach(label, 0, 1, ii, ii+1)
    label = make_label("<b>Version</b>")
    @table.attach(label, 1, 2, ii, ii+1)
    label = make_label("<b>State</b>")
    @table.attach(label, 2, 3, ii, ii+1)
    label = make_label("<b>Requires</b>")
    @table.attach(label, 4, 5, ii, ii+1)
    label = make_label("<b>Extension Points(Connected Plugins)</b>")
    @table.attach(label, 5, 6, ii, ii+1)

    # now the data for each plugin
    ii += 1
    data.each do |item|
      label = make_label(item[:name])
      @table.attach(label, 0, 1, ii, ii+1)
      label = make_label(item[:version])
      @table.attach(label, 1, 2, ii, ii+1)
      
      # Show the state, with a toggle for stopping/starting plugins
      #label = make_label(item[:state].to_s)
      #@table.attach(label, 2, 3, ii, ii+1)
      
      image = nil
      if item[:state] == :started
        image = Gtk::Image.new("#{dirname}/images/plugin.png")
      elsif item[:state] == :stopped
        image = Gtk::Image.new("#{dirname}/images/plugin_disabled.png")
      else
        image = Gtk::Image.new("#{dirname}/images/plugin_error.png")
      end
      @table.attach(image, 2, 3, ii, ii+1)

      
      check = Gtk::CheckButton.new
      check.active = item[:state] == :started
      check.signal_connect("toggled") do
        begin
          if check.active?
            @logger.debug { "User wants to start plugin #{item[:name].to_sym.inspect}" }
            PlugMan.start_plugin(item[:name].to_sym)
          else
            @logger.debug { "User wants to stop plugin #{item[:name].to_sym.inspect}" }
            PlugMan.stop_plugin(item[:name].to_sym)
          end
        rescue PluginError => err
          @logger.error { "Plugin error occured for plugin #{item[:name].to_s}, type: #{err.error_type}." }
        end
        display
      end
      @table.attach(check, 3, 4, ii, ii+1)
      
      label = make_label(item[:requires].join(", "))
      @table.attach(label, 4, 5, ii, ii+1)

      txt = []
      item[:extension_points].each do |ext|
        txt << ext[:name] + "(" + ext[:connections].join(", ") + ")"
      end
      label = make_label(txt.join(", "))
      @table.attach(label, 5, 6, ii, ii+1)
      
      ii += 1
    end
    @box.pack_start(@table, true, true, 0)
    @box.show_all
    @box
  end
  
  def get_data()
    PlugMan.registered_plugins[:plugin_data].data
  end
end
