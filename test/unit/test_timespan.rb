require 'achoo/temporal'
require 'test_helpers'

class TestTimespan < Test::Unit::TestCase

  context 'Contains with timeish argument' do
    setup do
      @ts = Achoo::Temporal::Timespan.new('1970-01-01', '1970-01-02')
    end
    
    should "contain it's start" do
      assert(@ts.contains?('1970-01-01'))
    end

    should "contain it's end" do
      assert(@ts.contains?('1970-01-02'))
    end

    should "contain an intervening time" do
      assert(@ts.contains?('1970-01-01 23:30'))
    end

    should "not contain a time after end time" do
      assert(!@ts.contains?('1970-01-03'))
    end
  end

  context 'Contains with timespan argument' do
    setup do
      @ts = Achoo::Temporal::Timespan.new('1970-01-01', '1970-01-02')
    end

    should 'contain self' do
      assert(@ts.contains?(@ts))
    end

    should 'contain intervening timespan' do
      assert(@ts.contains?(Achoo::Temporal::Timespan.new('1970-01-01 06:00', 
                                                         '1970-01-01 09:00 ')))
    end

    should 'not contain timespan with end after end time' do
      assert(!@ts.contains?(Achoo::Temporal::Timespan.new('1970-01-01 06:00',
                                                          '1970-01-02 09:00 ')))
    end
  end

end
