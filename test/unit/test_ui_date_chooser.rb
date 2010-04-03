require 'achoo/ui/date_chooser'
require 'date'
require 'test/unit'

class TestUIDateChooser < Test::Unit::TestCase

  def setup
    @x     = Achoo::UI::DateChooser.new
    @today = Date.today
  end
  
  # def teardown
  # end

  def test_relative_negative
    assert_equal @today-1, @x.parse_date('-1')
  end

  def test_relative_positive
    assert_equal @today+1, @x.parse_date('+1')
  end

  def test_absolute_notation
    assert_equal @today, @x.parse_date(@today.day.to_s)
    assert_equal @today, @x.parse_date("#{@today.month}-#{@today.day}")
    assert_equal @today, @x.parse_date("#{@today.year}-#{@today.month}-#{@today.day}")
  end

  def test_simplified_absolute_notation
    assert_equal Date.civil(2010, 1, 1), @x.parse_date('2010-1-1')
    assert_equal Date.civil(2010, 1, 1), @x.parse_date('2010-01-01')
    assert_equal Date.civil(2010, 1, 1), @x.parse_date('10-1-1')
  end

end

