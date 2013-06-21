PlugMan.define :reverse do
  author "Aaron"
  version "1.0.0"
  extends({ :main => [:transform] })
  requires []
  extension_points []
  params({ :description => "Reverses the input text." })
  
  def xform(str)
    str.reverse
  end
end
