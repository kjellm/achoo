require 'test_helpers'

class TestLockMonth < Test::Unit::TestCase

  include AcceptanceBase

  def setup
    super

    time_registration_html = %q{
      <html>
      <head></head>
      <body>
        <form name="entryform">

          <input type="hidden" name="action" value="foo">
          <input type="hidden" name="atkaction" value="bar">

          <select name="activitydate[day]">
            <option value="1" >Saturday 1</option>
            <option value="2" >Sunday 2</option>
            <option value="3" >Monday 3</option>
            <option value="4" >Tuesday 4</option>
            <option value="5" >Wednesday 5</option>
            <option value="6" >Thursday 6</option>
            <option value="7" >Friday 7</option>
            <option value="8" >Saturday 8</option>
            <option value="9" >Sunday 9</option>
            <option value="10" >Monday 10</option>
            <option value="11" >Tuesday 11</option>
            <option value="12" >Wednesday 12</option>
            <option value="13" >Thursday 13</option>
            <option value="14" >Friday 14</option>
            <option value="15" >Saturday 15</option>
            <option value="16" >Sunday 16</option>
            <option value="17" >Monday 17</option>
            <option value="18" >Tuesday 18</option>
            <option value="19" >Wednesday 19</option>
            <option value="20" >Thursday 20</option>
            <option value="21" >Friday 21</option>
            <option value="22" >Saturday 22</option>
            <option value="23" >Sunday 23</option>
            <option value="24" >Monday 24</option>
            <option value="25" selected>Tuesday 25</option>
            <option value="26" >Wednesday 26</option>
            <option value="27" >Thursday 27</option>
            <option value="28" >Friday 28</option>
            <option value="29" >Saturday 29</option>
            <option value="30" >Sunday 30</option>
            <option value="31" >Monday 31</option>
          </select>

          <select name="activitydate[month]">
            <option value="1" >January</option>
            <option value="2" >February</option>
            <option value="3" >March</option>
            <option value="4" >April</option>
            <option value="5" selected>May</option>
            <option value="6" >June</option>
            <option value="7" >July</option>
            <option value="8" >August</option>
            <option value="9" >September</option>
            <option value="10" >October</option>
            <option value="11" >November</option>
            <option value="12" >December</option>
          </select>

          <input type="text" name="activitydate[year]" value="2010">

          <a href="FIX">Select range</a>

          <select name="projectid">
            <option value="project.id='1'" >foo: Foo</option>
            <option value="project.id='2'" >bar: Bar</option>
          </select>

          <a href="FIX">Select project</a>

          <select name="phaseid"></select>

          <textarea name='remark'></textarea>

          <input name="time" value="">

          <select name="workperiod">
            <option value="workperiod.id='1'" selected>Normal</option>
            <option value="workperiod.id='2'" >Overtime</option>
          </select>

          <select name="billpercent">
            <option value="billpercent.id='1'" >Normal (100%)</option>
            <option value="billpercent.id='2'" >Overtime (200%)</option>
          </select>

          <input type="submit" value="Save">
        </form>
      </body>
      </html>
    }

    phase_html = %q{The phase&nbsp;&nbsp;<input type="hidden" name="phaseid" value="phase.id='1'">}

    @server.register(:get, '/time_registration', [ 200, nil, time_registration_html ])
    @server.register(:post, '/dispatch.php', [ 200, nil, phase_html ])
  end
    
  def test_register_hours
    achoo(:verbose => ENV['ACHOO_DEBUG']) do
      expect '1. Register hours'
      expect_main_prompt
      puts '1'

      expect /Date \(\[today\] \| \?\)>/
      puts '2010-05-25'

      expect 'Recently used projects'
      expect '1. foo: Foo'
      expect '2. bar: Bar'
      puts '2'

      expect 'Phases'
      expect '1. The phase'

      expect 'Remark>'
      puts 'A nice remark'

      expect 'Hours [7:30]>'
      puts '2'

      # Bug in expect? 
      # Can't check for the whole string
      # expect 'Do you want to change the defaults for worktime period and/or billing percentage? [N/y]>'
      expect 'Do you want to change the defaults for worktime period and/or billing percent'
      puts 'y'

      expect 'Worktime periods'
      expect '1. Normal'
      expect '2. Overtime'
      expect 'Period [1]>'
      puts '2'

      expect 'Billing options'
      expect '1. Normal (100%)'
      expect '2. Overtime (200%)'
      expect 'Billing [1]>'
      puts '2'

      expect '     date: "2010-05-25"'
      expect '  project: "bar: Bar"'
      expect '    phase: "The phase"'
      expect '   remark: "A nice remark"'
      expect '    hours: "2"'
      expect ' worktime: "Overtime"'
      expect '  billing: "Overtime (200%)"'

      expect 'Submit? [Y/n]>'
      puts 'n'

      expect 'Cancelled'
      expect_main_prompt
      puts 'q'
    end
  end
end
