require 'achoo/system'
require 'test_helpers'

class TestSystemLogEntry < Test::Unit::TestCase

  context 'Comparison' do

    setup do
      @a = Achoo::System::LogEntry.new(1, :foo)
      @b = Achoo::System::LogEntry.new(1, :bar)
      @c = Achoo::System::LogEntry.new(2, :baz)
    end

    should 'eq' do
      assert(@a == @b)
      assert(!(@a == @c))
    end

    should 'lt' do
      assert(@a < @c)
      assert(!(@c < @a))
    end

    should 'le' do
      assert(@a <= @b)
      assert(@a <= @c)
    end

  end
end

