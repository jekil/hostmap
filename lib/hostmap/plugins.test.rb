$:.unshift(File.join(File.expand_path(File.dirname(__FILE__))))

require "test/unit"
require 'plugins'
require 'timeout'

class PluginContinerTest < Test::Unit::TestCase
  def setup
    #@plugin_loaded = Hostmap::Plugins::PluginContainer.new("../discovery/test/stub")
    @plugin_empty = Hostmap::Plugins::PluginContainer.new("../discovery/")
  end

  def test_empty
    assert_nil @plugin_empty.plugin
  end
end


class PluginLoaderTest < Test::Unit::TestCase
  def setup
    @pl = Hostmap::Plugins::PluginLoader.new
  end

  def test_search
    @pl.search
    assert_not_equal @pl.paths.size, 0
  end
end



