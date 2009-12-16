PlugMan.define :case_swap_reverse do
  author "Aaron"
  version "1.0.0"
  extends({ :main => [:transform] })
  requires [:case_swap, :reverse]
  extension_points []
  params({ :description => "Swaps case and reverses the input text, using other plugins." })
  
  def xform(str)
    ret = PlugMan.registered_plugins[:case_swap].xform(str)
    PlugMan.registered_plugins[:reverse].xform(ret)
  end
end
