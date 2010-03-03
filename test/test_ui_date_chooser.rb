require 'achoo/ui/date_chooser'
require 'test/unit'

class TestUIDateChooser < Test::Unit::TestCase

  include Achoo::UI::DateChooser

  # def setup
  # end
  
  # def teardown
  # end

  def test_parse_date
    today = Date.today
    assert_equal today-1, parse_date('-1')
    assert_equal today+1, parse_date('+1')

    assert_equal today, parse_date(today.day.to_s)
    assert_equal today, parse_date("#{today.month}-#{today.day}")
    assert_equal today, parse_date("#{today.year}-#{today.month}-#{today.day}")

    assert_equal Date.civil(2010, 1, 1), parse_date('2010-1-1')
    assert_equal Date.civil(2010, 1, 1), parse_date('2010-01-01')
    assert_equal Date.civil(2010, 1, 1), parse_date('10-1-1')
  end

end

