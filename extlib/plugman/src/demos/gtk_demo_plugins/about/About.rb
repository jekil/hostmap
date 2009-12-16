PlugMan.define :about do
  author "Aaron"
  version "1.0.0"
  extends(:workbench => [:work_area])
  requires []
  extension_points []
  params(:ui_label => "About", :ui_image => "#{dirname}/images/comment.png")
  
  def get_ui()
    # load the work area UI
    display
  end
  
  def display()
    @logger.debug { "About displaying" }
    box = Gtk::HBox.new
    label = Gtk::Label.new
    label.set_markup("\n\n\n<big><big><big><b>PlugMan v. #{PlugMan::PLUGMAN_VERSION}</b></big></big>\n\n\nProject home: http://rubyforge.org/projects/plugman/</big>\n\n\n\n\n\n\n\n\n\n\nIcons from http://www.famfamfam.com/lab/icons/silk/")
    label.set_justify(Gtk::JUSTIFY_CENTER)
    box.pack_start(label, true, true, 0)
    
    box
  end  
end
