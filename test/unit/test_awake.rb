require 'achoo/awake'
require 'stringio'
require 'test/unit'
require 'time'

class Achoo::Awake
  
  def initialize
    log = [
           [ '2010-03-01 07:00', :boot],
           [ '2010-03-01 11:40', :suspend],
           # Crash
           [ '2010-03-01 13:00', :boot],
           [ '2010-03-01 18:00', :halt],
           #
           [ '2010-03-02 07:00', :boot],
           [ '2010-03-02 08:00', :suspend],
           [ '2010-03-02 09:00', :awake],
           [ '2010-03-02 10:00', :suspend],
           [ '2010-03-03 11:00', :awake],
           [ '2010-03-03 12:00', :halt],
           # 
           [ '2010-03-04 07:00', :boot],
           # Crash
           [ '2010-03-05 07:00', :boot],
           [ '2010-03-05 08:00', :suspend],
           [ '2010-03-05 09:00', :awake],
           # Crash
           [ '2010-03-05 10:00', :boot],
          ].reverse
    log.unshift(['2010-03-05 18:00', :now])

    log.each {|entry| entry[0] = Time.parse(entry[0])}

    @sessions = sessions(log)
  end

end


class TestAwake < Test::Unit::TestCase

  def setup
    @awake = Achoo::Awake.new
  end
  
  #def teardown
  #end

  def test_all
    $stdout = StringIO.new

    @awake.all
    expected = %q{Powered on: (0+08:00) Fri  5. Mar 2010 10:00 - 18:00
Powered on: (?+??:??) Fri  5. Mar 2010 07:00 - ?
  Awake: (?+??:??) Fri  5. Mar 2010 09:00 - ?
  Awake: (0+01:00) Fri  5. Mar 2010 07:00 - 08:00
Powered on: (?+??:??) Thu  4. Mar 2010 07:00 - ?
Powered on: (1+05:00) Tue  2. Mar 2010 07:00 - Wed  3. Mar 2010 12:00
  Awake: (0+01:00) Wed  3. Mar 2010 11:00 - 12:00
  Awake: (0+01:00) Tue  2. Mar 2010 09:00 - 10:00
  Awake: (0+01:00) Tue  2. Mar 2010 07:00 - 08:00
Powered on: (0+05:00) Mon  1. Mar 2010 13:00 - 18:00
Powered on: (0+04:40) Mon  1. Mar 2010 07:00 - 11:40
}
    actual = $stdout.string
    $stdout = STDOUT
    assert_equal(expected, actual)
  end

  def test_at_1
    $stdout = StringIO.new

    @awake.at(Date.new(2010, 3, 2))
    expected = %q{Powered on: (1+05:00) Tue  2. Mar 2010 07:00 - Wed  3. Mar 2010 12:00
  Awake: (0+01:00) Tue  2. Mar 2010 09:00 - 10:00
  Awake: (0+01:00) Tue  2. Mar 2010 07:00 - 08:00
}
    actual = $stdout.string
    $stdout = STDOUT
    assert_equal(expected, actual)
  end

  def test_at_2
    $stdout = StringIO.new

    @awake.at(Date.new(2010, 3, 3))
    expected = %q{Powered on: (1+05:00) Tue  2. Mar 2010 07:00 - Wed  3. Mar 2010 12:00
  Awake: (0+01:00) Wed  3. Mar 2010 11:00 - 12:00
}
    actual = $stdout.string
    $stdout = STDOUT
    assert_equal(expected, actual)
  end

end
