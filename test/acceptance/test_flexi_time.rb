require 'test_helpers'

class TestFlexiTime < Test::Unit::TestCase

  include AcceptanceBase

  def setup
    super
    
    hour_administration_html = %q{
      <html>
      <head></head>
      <body>
        <form name="dayview">
          <input type="text" name="viewdate[day]"   value="20">
          <input type="text" name="viewdate[month]" value="03">
          <input type="text" name="viewdate[year]"  value="2010">
        </form>
      
        <p>Flexi time balance: -44:30</p>
      
      </body>
      </html>
    }

    @server.register( { 'REQUEST_METHOD' => 'GET', 'REQUEST_PATH' => '/time_registration' }, [ 200, nil, hour_administration_html ])
  end

  def test_flexi_time
    achoo(:verbose => false) do |r, w|
      _expect(r, '2. Show flexitime balance')
      expect_main_prompt(r)
      w.puts '2'
      w.puts '2010-03-20'
      _expect(r, /Flexi time balance:.*-44:30/)
      expect_main_prompt(r)
      w.puts 'q'
    end
  end

end
