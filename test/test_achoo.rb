require 'achoo'
require 'test/unit'

class TestAchoo < Test::Unit::TestCase
  # def setup
  # end
  
  # def teardown
  # end

  def test_parse_date
    a = Achoo.new
    today = Date.today
    assert_equal today-1, a.parse_date('-1')
    assert_equal today+1, a.parse_date('+1')

    assert_equal today, a.parse_date(today.day.to_s)
    assert_equal today, a.parse_date("#{today.month}-#{today.day}")
    assert_equal today, a.parse_date("#{today.year}-#{today.month}-#{today.day}")

    assert_equal Date.civil(2010, 1, 1), a.parse_date('2010-1-1')
    assert_equal Date.civil(2010, 1, 1), a.parse_date('2010-01-01')
    assert_equal Date.civil(2010, 1, 1), a.parse_date('10-1-1')
  end

end

