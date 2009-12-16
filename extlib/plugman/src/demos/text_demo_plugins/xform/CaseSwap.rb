PlugMan.define :case_swap do
  author "Aaron"
  version "1.0.0"
  extends({ :main => [:transform] })
  requires []
  extension_points []
  params({ :description => "Swaps the case of the input characters." })

  def xform(str)
    str.swapcase
  end
end
