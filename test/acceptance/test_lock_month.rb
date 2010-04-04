require 'achievo_mock'
require 'achoo_runner'

require 'achoo/term'
require 'test_helpers'

class TestLockMonth < Test::Unit::TestCase

  include AcceptanceBase

  def setup
    super

    lock_month_html = %q{
      <html>
      <head></head>
      <body>
        <form name="entryform">
          <input type="text" name="period"   value="">
        </form>
      </body>
      </html>
    }

    @server.register( { 'REQUEST_METHOD' => 'GET', 'REQUEST_PATH' => '/lock_months' }, [ 200, nil, lock_month_html ])
  end
    
  def test_lock_month
    achoo(:verbose => false) do |r, w|
      _expect(r, /6\. Lock month/)
      _expect(r, Achoo::Term::bold('[1]> '))
      w.puts '6'
      _expect(r, Achoo::Term::bold('Period ([201003] | YYYYMM)> '))
      w.puts
      _expect(r, 'Month: 201003')
      w.puts 'n'
      _expect(r, Achoo::Term::bold('[1]> '))
      w.puts 'q'
    end
  end
end
