require 'plugins'


class TestPlugin < Hostmap::Plugins::BasePlugin

  def info
    {
      :author => "Alessandro Tanasi",
      :version => "0.3",
      :require => :ip,
      :description => "Just a stub"
    }
  end

  def execute(value, opts = {})
    sleep value
  end
end