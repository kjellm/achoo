require 'achoo/awake'
require 'test/unit'


class Achoo::Awake
  
  def initialize
    log = [
           [14, :boot],
           # Crash
           [13, :awake],
           [12, :suspend],
           [11, :boot],
           # Crash
           [10, :boot],
           # 
           [ 9, :halt],
           [ 8, :awake],
           [ 7, :suspend],
           [ 6, :awake],
           [ 5, :suspend],
           [ 4, :boot],
           #
           [ 3, :halt],
           [ 2, :boot],
           # Crash
           [ 1, :suspend],
           [ 0, :boot],
          ]

    log.unshift([Time.now, :now])
    @sessions = to_intervals(log)
  end

end


class TestAwake < Test::Unit::TestCase

  def setup
    @awake = Achoo::Awake.new
  end
  
  #def teardown
  #end

  def test_ok
    assert true
  end

end
