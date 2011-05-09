#require 'redgreen' # FIX Seems to be problems with ruby 1.9.2 due to minitest/unit
require 'shoulda'
require 'test/unit'

require 'achievo_mock'
require 'achoo_runner'

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
    @server.register(:get, '/',     [ 200, nil, @@main_html ])
    @server.register(:get, '/menu', [ 200, nil, @@menu_html ])
  end

  def teardown
    @server.stop
  end

end
