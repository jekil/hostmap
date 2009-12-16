PlugMan.define :df do
  author "Aaron"
  version "1.0.0"
  extends(:workbench => [:work_area])
  requires [:df_ui]
  extension_points []
  params(:ui_label => "DiskFree", :ui_image => "#{dirname}/images/disk.png")

  def get_ui()
    # load the work area UI
    PlugMan.registered_plugins[:df_ui].display
  end
end
