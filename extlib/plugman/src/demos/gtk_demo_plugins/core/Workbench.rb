require 'gtk2'
require "observer"

PlugMan.define :workbench do
  author "Aaron"
  version "1.0.0"
  extends(:core => [:app_start])
  requires []
  extension_points [:work_area]
  
  def start()
    @logger.debug { "Workbench starting, creating empty plugin to ui widget map" }
    @plug_ui = {}
    
    true
  end

  
  def app_start()
    construct_workbench
    @logger.debug { "Adding workbench plugin as observer to plugman" }
    PlugMan.add_observer(self)
    @logger.debug { "Starting GUI." }
    Gtk.main
  end

  def construct_workbench()
    @logger.debug { "Constructing workbench" }
    
    # construct the UI workbench
    window = Gtk::Window.new("PlugMan Demo")
    window.icon = Gdk::Pixbuf.new("#{dirname}/images/disconnect.png")
    @notebook = Gtk::Notebook.new()
    window.border_width = 10
    window.add(@notebook)
    window.set_default_size(640, 480) # TODO savable config item
    window.signal_connect("destroy") {
      Gtk.main_quit
    }
    
    # Add all the plugin displays
    @logger.debug{ "About to add UI plguins to workbench" }
    PlugMan.extensions(:workbench, :work_area).each do |plugin|
      @logger.debug{ "Adding plugin #{plugin.name.to_s} to the workbench" }
      ui = plugin.get_ui
      plugin.add_observer(self)
      @notebook.append_page(ui, make_tab_widget(plugin.params[:ui_label], plugin.params[:ui_image]))
      @plug_ui[plugin] = ui
    end

    window.show_all

  end
  
  def make_tab_widget(text, img_loc)
    tab_widget = Gtk::HBox.new
    image = Gtk::Image.new(img_loc)
    label = Gtk::Label.new(text, true)
    tab_widget.pack_start(image)
    tab_widget.pack_start(label)
    tab_widget.resize_children
    tab_widget.show_all
    tab_widget
  end

  # update the notebook if the plugin is dependent on the workbench
  def update(state, plugin)
    if !@notebook.destroyed? && (plugin.requires.include?(:workbench) || (plugin.extends && plugin.extends.keys.include?(name)))

      # remove any trace of the plugin from the workbench
      page_num = @notebook.page_num(@plug_ui[plugin])
      if page_num != -1
        @notebook.remove_page(page_num)
        @plug_ui[plugin] = nil
      end

      @logger.debug { "Workbench update event thrown, state #{state.inspect} for plugin #{plugin.name.to_s}" }
      if state == :started
        ui = plugin.get_ui
        plugin.add_observer(self)
        @notebook.append_page(ui, make_tab_widget(plugin.params[:ui_label], plugin.params[:ui_image]))
        @plug_ui[plugin] = ui
      elsif state == :stopped
        # already removed UI from workbench...
      else
        error_label = Gtk::Label.new("Bad state #{state.inspect} for plugin #{plugin.name.inspect}.")
        @plug_ui[plugin] = error_label
        @notebook.append_page(ui, make_tab_widget(plugin.params[:ui_label], plugin.params[:ui_image]))
      end
      @notebook.show_all
    end
  end
end
