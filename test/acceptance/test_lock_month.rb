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

    @server.register(:get, '/lock_months', [ 200, nil, lock_month_html ])
  end
    
  def test_lock_month
    achoo(:verbose => $DEBUG) do
      expect '6. Lock month'
      expect_main_prompt
      puts '6'
      expect /Period \(\[\d{6}\] | YYYYMM\)>/
      puts '201003'
      expect 'Month: 201003'
      expect 'Submit? [Y/n]>'
      puts 'n'
      expect 'Cancelled'
      expect_main_prompt
      puts 'q'
    end
  end
end
