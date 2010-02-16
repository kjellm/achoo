class Achoo; end

require 'achoo/vcs'
require 'achoo/hour_administration_form'
require 'achoo/hour_registration_form'
require 'achoo/lock_month_form'
require 'achoo/last'
require 'logger'
require 'mechanize'

class Achoo

  def initialize(log=false)
    @agent = Mechanize.new
    if log
      @agent.log = Logger.new("achoo_http.log")
    end
  end

  def start
    print_welcome
    login
    scrape_urls
    command_loop
  end


  def command_loop
    while true
      answer = Term.menu('[1]',
                         ["Register hours",
                          "Show flexitime balance",
                          "Day hour report",
                          "Week hour report",
                          "Holiday balance",
                          "Lock month",
                         ],
                         "Exit",
                         ['q', 'Q', ''])
      case answer
      when '0', 'q', 'Q'
        exit
      when '1', ''
        register_hours
      when '2'
        show_flexi_time
      when '3'
        show_registered_hours_for_day
      when '4'
        show_registered_hours_for_week
      when '5'
        show_holiday_report
      when '6'
        lock_month
      end
    end
  end

  def scrape_urls 
    page = @agent.get(@agent.current_page.frames.find {|f| f.name == 'menu'}.href)
    menu_links = page.search('a.menuItemLevel2')
    
    RC[:hour_registration_url] = menu_link_to_url(menu_links, 'Time Registration')
    RC[:lock_months_url]       = menu_link_to_url(menu_links, 'Lock months')
    RC[:holiday_report_url]    = menu_link_to_url(menu_links, 'Holiday report')
    RC[:hour_admin_url]        = RC[:hour_registration_url]
  end

  def menu_link_to_url(menu_links, text)
    url = menu_links.find {|a| 
      a.text.strip == text
    }.attribute('onclick').value.match(/window\.open\('([^']+)/)[1]
    return "#{RC[:url]}#{url}"
  end

  def register_hours
    form = HourRegistrationForm.new(@agent)
    
    date         = date_chooser
    form.date    = date
    form.project = project_chooser(form)
    form.phase   = phase_chooser(form)
    form.remark  = get_remark(date)
    form.hours   = hours_chooser(date)

    form.print_values
    if confirm
      puts "Submitting ..."
      form.submit
    else
      puts "Cancelled"
    end
  end


  def phase_chooser(form)
    phases = form.phases_for_selected_project
    puts "Phases"
    answer = Term.menu('Phase ID', phases.collect {|p| p[1] })
    phases[answer.to_i-1][0]
  end


  def show_registered_hours_for_day
    date = date_chooser
    form = HourAdministrationForm.new(@agent)
    form.show_registered_hours_for_day(date)
  end

  def show_registered_hours_for_week
    date = date_chooser
    form = HourAdministrationForm.new(@agent)
    form.show_registered_hours_for_week(date)
  end


  def show_flexi_time
    date = date_chooser
    form = HourAdministrationForm.new(@agent)
    balance = form.flexi_time(date)
    puts "Flexi time balance: #{Term::underline(balance)}"
  end


  def lock_month
    month = month_chooser
    form   = LockMonthForm.new(@agent)
    form.lock_month(month)
    form.print_values
    if confirm
      form.submit
    else
      puts "Cancelled"
    end
  end

  
  def month_chooser
    default = one_month_ago
    period = Term::ask "Period ([#{default}] | YYYYMM)"
    period = default if period.empty?
    # FIX validate YYYYMM
    period
  end


  def one_month_ago
    now   = Time.now
    year  = now.year

    # Use -2 + 1 to shift range from 0-11 to 1-12 
    month = (now.month - 2)%12 + 1
    year -= 1 if month > now.month

    sprintf "%d%02d", year, month
  end
    

  def show_holiday_report
    page = @agent.get(RC[:holiday_report_url])
    page.body.match(/<b>(\d+,\d+)<\/b>/)
    puts "Balance: #{Term::underline($1)}"
  end


  def confirm
    answer = Term::ask "Submit? [Y/n]"
    answer.downcase!
    return answer == 'y' || answer == ''
  end


  def hours_chooser(date)
    puts "Last log:"
    last = Last.new
    last.find_by_date(date)
    puts
    answer = Term::ask 'Hours [7:30]'
    return answer == '' ? '7.5' : answer
  end


  def get_remark(date)
    puts "VCS logs for #{date}:"

    RC[:vcs_dirs].each do |dir|
      Dir.glob("#{dir}/*/").each do |dir|
        vcs = VCS.factory(dir)
        if vcs.nil?
          puts "!!! Unrecognized vcs in dirctory: #{dir}"
        else
          vcs.print_log_for(date)
        end
      end
    end
    Term::ask 'Remark'
  end


  def project_chooser(form)
    puts 'Recently used projects'
    projects = form.recent_projects
    answer = Term.menu('Project [1]', projects.collect { |p| p[1] },
                       'Other', [''])
    case answer
    when ''
      projects[0][0]
    when '0'
      return all_projects_chooser(form)
    else
      return projects[answer.to_i-1][0]
    end
  end


  def all_projects_chooser(form)
    projects = form.all_projects
    answer = Term.menu('Project', projects.collect { |p| p[1] })
    projects[answer.to_i-1][0]
  end


  def login
    load_cookies

    page = @agent.get(RC[:url])

    return if page.forms.empty?

    puts "Logging in ..."

    form = page.forms.first
    form.auth_user = RC[:user]
    form.auth_pw   = RC[:password]
    page = @agent.submit(form, form.buttons.first)

    if page.body.match(/Username and\/or password are incorrect. Please try again./)
      warn "Username and/or password are incorrect."
      exit 2
    end

    @agent.cookie_jar.save_as("#{ENV['HOME']}/.achoo_cookies.yml")
  end


  def load_cookies
    cookies_file = "#{ENV['HOME']}/.achoo_cookies.yml"
    if FileTest.exists? cookies_file
      @agent.cookie_jar.load(cookies_file)
    end
  end


  def print_welcome
    puts "Welcome to Achoo!"
  end


  def date_chooser
    while true
      begin
        answer = Term::ask "Date ([today] | ?)"
        case answer
        when '?'
          puts "Accepted formats:"
          puts "\t today | (+|-)n | [[[YY]YY]-[M]M]-[D]D"
          puts
          system 'cal -3m'
        when '', 'today'
          return Date.today
        else
          return parse_date(answer)
        end
      rescue ArgumentError => e
        puts e.message
      end
    end
  end


  def parse_date(date_str)
    today = Date.today
    case date_str.chars.first
    when '-'
      return today - date_str[1..-1].to_i
    when '+'
      return today + date_str[1..-1].to_i
    end
    
    date = date_str.split('-').collect {|d| d.to_i}
    case date.length
    when 1
      return Date.civil(today.year, today.month, *date)
    when 2
      return Date.civil(today.year, *date)
    when 3
      date[0] += 2000 if date[0] < 100
      return Date.civil(*date)
    end
  end
  
end

