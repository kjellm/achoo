require 'achoo/extensions'
require 'test_helpers'

class TestExtensionsArray < Test::Unit::TestCase

  context 'merge!' do
    setup do
      @expected = (1..8).to_a
    end

    should 'merge two sorted arrays with interleaving values' do
      assert_equal @expected, [1,3,5,7].merge!([2,4,6,8])
    end

    should 'merge two sorted arrays where A > B' do
      assert_equal @expected, (1..4).to_a.merge!((5..8).to_a)
    end

    should 'merge two sorted arrays where A < B' do
      assert_equal @expected, (5..8).to_a.merge!((1..4).to_a)
    end
  end

end

