require 'achoo/timespan'

class TestTimespan < Test::Unit::TestCase
  # def setup
  # end
  
  # def teardown
  # end

  def test_contains_with_timeish
    ts = Achoo::Timespan.new('1970-01-01', '1970-01-02')
    assert(ts.contains?('1970-01-01'))
    assert(ts.contains?('1970-01-02'))
    assert(ts.contains?('1970-01-01 23:30'))

    assert(!ts.contains?('1970-01-03'))
  end

  def test_contains_with_interval
    ts = Achoo::Timespan.new('1970-01-01', '1970-01-02')

    assert(ts.contains?(Achoo::Timespan.new('1970-01-01', '1970-01-02')))
    assert(ts.contains?(Achoo::Timespan.new('1970-01-01 06:00', '1970-01-01 09:00 ')))

    assert(!ts.contains?(Achoo::Timespan.new('1970-01-01 06:00', '1970-01-02 09:00 ')))
  end

end

