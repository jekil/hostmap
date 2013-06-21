PlugMan.define :crypto do
  author "Aaron"
  version "1.0.0"
  extends({ :main => [:transform] })
  requires []
  extension_points []
  params({ :description => "Encrypts the input." })

  def xform(str)
    salt = "XX"
    str.crypt(salt)
  end
end
