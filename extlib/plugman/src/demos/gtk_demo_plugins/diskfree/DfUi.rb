PlugMan.define :df_ui do
  author "Aaron"
  version "1.0.0"
  extends
  requires [:df_data]
  extension_points [:work_area]
  params()
 
  def make_label(str, open_tags = "", close_tags = "")
    xpad = 10
    xalign = 0.0
    label = Gtk::Label.new
    label.set_markup(open_tags + str + close_tags)
    label.xalign = xalign
    label.xpad = xpad
    label
  end
  
  def display()
    data = get_data()
    table = Gtk::Table.new(data.size, 6, false)
    ii = 0
    table.attach(make_label("Device", "<b>", "</b>"), 0, 1, ii, ii+1)
    table.attach(make_label("Mount Point", "<b>", "</b>"), 1, 2, ii, ii+1)
    table.attach(make_label("Usage", "<b>", "</b>"), 2, 3, ii, ii+1)
    table.attach(make_label("Free", "<b>", "</b>"), 3, 4, ii, ii+1)
    table.attach(make_label("%", "<b>", "</b>"), 4, 5, ii, ii+1)

    ii += 1
    data.each do |item|
      
      # low value warning in red.
      perc = item[:perc].sub(/%/, "").to_i
      op = cl = ""
      if perc > 90
        op = "<span foreground='red'>"
        cl = "</span>"
      else
        
      end
      table.attach(make_label(item[:device], op, cl), 0, 1, ii, ii+1)
      table.attach(make_label(item[:mount], op, cl), 1, 2, ii, ii+1)
      table.attach(make_label(item[:used] + " / " + item[:size], op, cl), 2, 3, ii, ii+1)
      table.attach(make_label(item[:avail], op, cl), 3, 4, ii, ii+1)
      prog = Gtk::ProgressBar.new
      prog.text = item[:perc]
      prog.fraction = perc / 100.0
      table.attach(prog, 4, 5, ii, ii+1)
      
      ii += 1
    end
    table
  end
  
  def get_data()
    PlugMan.registered_plugins[:df_data].data
  end
end
