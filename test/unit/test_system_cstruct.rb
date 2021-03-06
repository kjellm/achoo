require 'achoo/system'
require 'test_helpers'

class TestSystemCStruct < Test::Unit::TestCase
  # def setup
  # end
  
  # def teardown
  # end

  class TestStruct < Achoo::System::CStruct
    long   :a
    string :b, 2
  end

  def test_cstruct
    ts   = TestStruct.new
    ts.a = 1
    ts.b = "hi"

    ts2 = TestStruct.new(ts.pack)

    assert_equal(ts.a, ts2.a)
    assert_equal(ts.b, ts2.b)
  end

end

