require 'achievo_mock'
require 'achoo_runner'

require 'achoo/term'
require 'test/unit'

class TestFlexiTime < Test::Unit::TestCase

  @@main_html = %q{
    <html>
    <head></head>
      <frameset>
        <frame name="menu" src="/menu">
      <frameset>
    </html>
  }

  @@menu_html = %q{
    <html>
    <head></head>
    <body>
      <a class="menuItemLevel2" 
         onclick="window.open('time_registration')">Time Registration</a>
      <a class="menuItemLevel2" 
         onclick="window.open('lock_months')">Lock months</a>
      <a class="menuItemLevel2" 
         onclick="window.open('holiday_report')">Holiday report</a>
    </body>
    </html>
  }

  @@hour_administration_html = %q{
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

  def setup
    @server = AchievoMock.new()
    @server.register( { 'REQUEST_METHOD' => 'GET', 'REQUEST_PATH' => '/'  },    [ 200, nil, @@main_html ])
    @server.register( { 'REQUEST_METHOD' => 'GET', 'REQUEST_PATH' => '/menu' }, [ 200, nil, @@menu_html ])
  end

  def teardown
    @server.stop
  end


  def _expect(r, pattern)
    stat = r.expect(pattern, 3)
    raise "Didn't find #{pattern} before timeout" if stat.nil?
    stat
  end

  def test_flexi_time
    @server.register( { 'REQUEST_METHOD' => 'GET', 'REQUEST_PATH' => '/time_registration' }, [ 200, nil, @@hour_administration_html ])

    achoo(:verbose => false) do |r, w|

      _expect(r, /\d+\. Show flexitime balance/)
      _expect(r, Achoo::Term::bold('[1]> '))
      w.puts '2'
      w.puts '2010-03-20'
      _expect(r, 'Flexi time balance: ' << Achoo::Term::underline('-44:30'))
      _expect(r, Achoo::Term::bold('[1]> '))
      w.puts 'q'
    end
  end
end
