PlugMan.define :fortune do
  author "Aaron"
  version "1.0.0"
  extends(:workbench => [:work_area])
  requires []
  extension_points []
  params(:ui_label => "Fortune", :ui_image => "#{dirname}/images/money.png")
  
  def get_ui()
    # load the work area UI
    display
  end
  
  def display()
    @logger.debug { "Fortune displaying" }
    box = Gtk::VBox.new
    label = Gtk::Label.new(`fortune`)
    box.pack_start(label, true, true, 0)
    button = Gtk::Button.new("Another?")  
    box.pack_start(button, false, false, 0)
    
    button.signal_connect("clicked") {
      label.text = `fortune`
    }
    box
  end  
end
