PlugMan.define :plugin_util do
  author "Aaron"
  version "1.0.0"
  extends(:workbench => [:work_area])
  requires [:plugin_ui]
  extension_points []
  params(:ui_label => "Plugin Utils", :ui_image => "#{dirname}/images/plugin.png")

  def get_ui()
    # load the work area UI
    PlugMan.registered_plugins[:plugin_ui].display
  end
end
