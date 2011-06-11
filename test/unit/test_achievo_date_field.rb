require 'achoo/achievo'
require 'test_helpers'

class TestTermMenu < Test::Unit::TestCase

  context 'Include' do
    setup do
      @a = Class.new do
        include Achoo::Achievo::DateField('foo', 'bar')
      end
    end

    should 'mixin foo accessor' do
      assert @a.instance_methods.include?(:foo)
    end

    should 'mixin foo= accessor' do
      assert @a.instance_methods.include?(:foo=)
    end
    
    should 'mixin foo_day_field accessor' do
      assert @a.instance_methods.include?(:foo_day_field)
    end

    should 'mixin foo_month_field accessor' do
      assert @a.instance_methods.include?(:foo_month_field)
    end

    should 'mixin foo_year_field accessor' do
      assert @a.instance_methods.include?(:foo_year_field)
    end
  end
end

