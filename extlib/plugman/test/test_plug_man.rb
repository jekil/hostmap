
$:.unshift File.join(File.dirname(__FILE__),'..','src')

require 'test/unit'
require "PlugMan"

# TODO: Test observer pattern for plugin state changes.
# TODO: Test multiple nested plugin dependencies
# TODO: Code coverage

class TestPlugMan < Test::Unit::TestCase

  # Check that PlugMan can't be initialized
  def test_no_init
    begin
      PlugMan.new
    rescue
      # expected...so no failing here
    else
      fail "Should have raised an exception."
    end
  end
  
  # Add some plugins and make sure they are all good
  def test_plugins
    ("A01".."A10").each do |nm|
      PlugMan.define nm.to_s.to_sym do
        author "Auth #{nm.to_s}"
        version "6.6.6"
        extends({ PlugMan::ROOT_PLUGIN => [PlugMan::ROOT_EXTENSION_POINT] })
        requires [PlugMan::ROOT_PLUGIN]
        extension_points ["ext_#{nm}".to_sym]
        params({ :p1 => "aa", :p2 => "bb" })
      
        #test method
        def do_true
          true
        end
      end
    end
    
    #test correct number added (don't forget :root!)
    assert_equal 11, PlugMan.registered_plugins.length, "Incorrect number of plugins defined."

    # No plugins should be started, so no plugins should be returned by
    # extensions()
    assert_equal(0, PlugMan.extensions(PlugMan::ROOT_PLUGIN, PlugMan::ROOT_EXTENSION_POINT).length, "(stopped plugins) Wrong number of plugins extending :root,:root")
    
    # start the plugins
    PlugMan.start_all_plugins
    
    # test number of plugins that require root
    assert_equal(10, PlugMan.required_by(PlugMan::ROOT_PLUGIN).length, "Wrong number of plugins depending on :root")

    # test the number of plugins that depend on root
    assert_equal 10, PlugMan.extensions(PlugMan::ROOT_PLUGIN, PlugMan::ROOT_EXTENSION_POINT).length, "Wrong number of dependent plugins for :root"

    # run a method on each plugin that extends root, and check it's params
    ii = 0
    PlugMan.extensions(PlugMan::ROOT_PLUGIN, PlugMan::ROOT_EXTENSION_POINT).each do |plug|
      ii += 1
      assert plug.do_true, "Plugin #{plug.name} didn't run return true for do_true()"
      assert_equal "aa", plug.params[:p1], "param 1 is bad for plugin #{plug.name}"
      assert_equal "bb", plug.params[:p2], "param 2 is bad for plugin #{plug.name}"
    end
    assert_equal 10, ii, "Wrong number of plugins ran for root extension point"
    
    # stop two plugins and check if the right number of extending plugins run
    PlugMan.stop_plugin(:A01)
    PlugMan.stop_plugin(:A10)
    ii = 0
    PlugMan.extensions(PlugMan::ROOT_PLUGIN, PlugMan::ROOT_EXTENSION_POINT).each do |plug|
      ii += 1
      assert plug.do_true, "Plugin #{plug.name} didn't run return true for do_true()"
      assert((plug.name != :A01 && plug.name != :A10), "A stopped plugin was run #{plug.name}")
    end
    assert_equal 8, ii, "Wrong number of plugins ran for root extension point"

    # stop the :root plugins and check the extends() (all other plugins should be stopped too.)
    PlugMan.stop_plugin(PlugMan::ROOT_PLUGIN)
    assert_equal(0, PlugMan.extensions(PlugMan::ROOT_PLUGIN, PlugMan::ROOT_EXTENSION_POINT).length, "(stopped plugins 2) Wrong number of plugins extending :root,:root")

    # all plugins should now be stopped, start :A01 and :root should also start because it is a dependency
    assert_equal :stopped, PlugMan.registered_plugins[PlugMan::ROOT_PLUGIN].state, ":root should be stopped"
    PlugMan.start_plugin(:A01)
    assert_equal :started, PlugMan.registered_plugins[:A01].state, ":A01 should be started"
    assert_equal :started, PlugMan.registered_plugins[PlugMan::ROOT_PLUGIN].state, ":root should be started"

  end
end
