PlugMan.define :df_data do
  author "Aaron"
  version "1.0.0"
  extends
  requires []
  extension_points []
  params()
  
  def data()
    parse_df
    @df_data
  end
  
  # run the df command for all mounted filesystems
  def parse_df
    @logger.debug { "Getting df output from system" }
    @df_data = []

    df = `df -hP \`mount | grep '^/dev' | cut -f 3 -d ' '\` | grep -v ^Filesystem`
    df.split("\n").each do |line|
      fields = line.split
      @df_data << {
        :device => fields[0],
        :size => fields[1],
        :used => fields[2],
        :avail => fields[3],
        :perc => fields[4],
        :mount => fields[5]
      }
    end
  end
end
