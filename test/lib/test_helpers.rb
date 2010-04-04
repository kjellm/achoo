require 'test/unit'
require 'redgreen'
require 'shoulda'

module AcceptanceBase 

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

  def expect_main_prompt(r)
    _expect(r, '[1]>')
  end

end
