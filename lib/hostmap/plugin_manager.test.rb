# Add hostmap library folder to path
base = __FILE__
#$:.unshift(File.join(File.expand_path(File.dirname(base)), 'lib'))
$:.unshift(File.join(File.expand_path(File.dirname(base)), '../extlib/plugman/src'))
$:.unshift(File.join(File.expand_path(File.dirname(base)), '../extlib/net-dns/lib'))

require "test/unit"
require 'plugin_manager'
require 'timeout'

class PluginManagerTest < Test::Unit::TestCase
  def setup
    @pool = Hostmap::Managers::ThreadPool.new(10)
  end

  def test_size_empty
    assert_equal(@pool.size, 0)
  end

  def test_size_with_one
    @pool.process { sleep 0.2}
    assert_equal(@pool.size, 1)
  end

  def test_size_with_two
    @pool.process { sleep 0.2}
    @pool.process { sleep 0.2}
    assert_equal(@pool.size, 2)
  end

  def test_size_with_one_consumed
    @pool.process { sleep 0.02}
    sleep 0.1
    assert_equal(@pool.size, 0)
  end

  def test_size_with_mixed
    @pool.process { sleep 0.1}
    assert_equal(@pool.size, 1)
    sleep 0.2
    assert_equal(@pool.size, 0)
    sleep 0.1
    assert_equal(@pool.size, 0)
    @pool.process { sleep 0.2}
    assert_equal(@pool.size, 1)
    @pool.process { sleep 0.1}
    assert_equal(@pool.size, 2)
    sleep 0.3
    assert_equal(@pool.size, 0)    
  end

  def test_pool_limit
    100.times { @pool.process { sleep 0.1} }
    assert_equal(@pool.size, 10)
    sleep 0.3
    assert_equal(@pool.size, 0)
    @pool = Hostmap::Managers::ThreadPool.new(10,20)
    100.times { @pool.process { sleep 0.2} }
    assert_equal(@pool.size, 20)
    sleep 0.3
    assert_equal(@pool.size, 0)
  end

  def test_busy
    assert_equal(@pool.busy?, false)
    @pool.process { sleep 0.2}
    assert_equal(@pool.busy?, true)
    sleep 0.3
    assert_equal(@pool.busy?, false)
    100.times { @pool.process { sleep 0.2} }
    assert_equal(@pool.busy?, true)
    sleep 0.3
    assert_equal(@pool.busy?, false)
  end

  def test_expire
    @pool = Hostmap::Managers::ThreadPool.new(0.1)
    assert_raise SystemExit do
      @pool.process { sleep 2 }
      @pool.join
    end
    assert_equal(@pool.size, 0)
    assert_raise SystemExit do
      @pool.process { sleep 2 }
      @pool.join
    end
  end

  def test_expire_many
    @pool = Hostmap::Managers::ThreadPool.new(0.1)
    count = 0
    100.times do
      begin
        @pool.process { sleep 2 }
        @pool.join
      rescue SystemExit
        count = count + 1
      end
    end
    assert_equal(count, 100)
  end

  def test_real_case
    @pool = Hostmap::Managers::ThreadPool.new(0.5)
    count = 0
    100.times do
      begin
        @pool.process { sleep rand }
        @pool.join
        count = count + 1
      rescue SystemExit
        count = count + 1
      end
    end
    assert_equal(count, 100)
  end
end