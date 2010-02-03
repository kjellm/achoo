require 'achoo/hour_administration_form'
require 'achoo/hour_registration_form'
require 'achoo/last'
require 'mechanize'


class Achoo

  def initialize
    @agent = WWW::Mechanize.new
  end

  def start
    print_welcome
    login

    scrape_urls

    command_loop
  end


  def command_loop
    while true
      print_menu
      case ask '[1]'
      when '0', 'q', 'Q'
        exit
      when '1', ''
        register_hours
      when '2'
        show_flexi_time
      when '3'
        show_registered_hours_for_day
      when '4'
        show_holiday_report
      when '5'
        lock_month
      else
        warn "Input error"
      end
    end
  end


  def print_menu
    puts "1. Register hours"
    puts "2. Show flexitime balance"
    puts "3. Show day"
    puts "4. Holidays"
    puts "5. Lock month"
    puts "0. Exit"
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
    form = Achoo::HourRegistrationForm.new(@agent)
    
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
    phases = form.phases_for_project
    puts "Phases"
    phases.each {|p| printf "%6d. %s\n", *p }
    if phases.length == 1
      return phases[0][0]
    else
      return ask 'Phase ID'
    end
  end


  def show_registered_hours_for_day
    date = date_chooser
    form = Achoo::HourAdministrationForm.new(@agent)
    form.show_registered_hours_for_day(date)
  end


  def show_flexi_time
    date = date_chooser
    form = Achoo::HourAdministrationForm.new(@agent)
    puts form.flexi_time(date)
  end


  def lock_month
    page  = @agent.get(RC[:lock_months_url])
    form  = page.form('entryform')
    period = ask "Period (YYYYMM)"
    form.period = period
    user_select = form.field_with(:name => 'userid')
    unless user_select.nil?
      user_select.options.each do |opt|
        if opt.text.match(/\(#{RC[:user]}\)$/)
          opt.select
        end
      end
    end
    puts "period: #{form.period}"
    puts "  user: #{user_select.value}" unless user_select.nil?
    if confirm
      form.submit
    else
      puts "Cancelled"
    end
  end


  def show_holiday_report
    page = @agent.get(RC[:holiday_report_url])
    page.body.match(/<b>(\d+,\d+)<\/b>/)
    puts "Balance: #$1"
  end


  def confirm
    answer = ask "Submit? [Y/n]"
    answer.downcase!
    return answer == 'y' || answer == ''
  end


  def hours_chooser(date)
    puts "Last log:"
    last = Achoo::Last.new
    print last.find_by_date(date).join("\n")
    puts
    return ask 'Hours'
  end


  def get_remark(date)
    puts "RCS logs for #{date}:"

    today    = date.strftime('%Y-%m-%d')
    tomorrow = date.next.strftime('%Y-%m-%d')

    RC[:vcs_dirs].each do |dir|
      Dir.glob("#{dir}/*/").each do |dir|
        puts "---------(#{dir})-------------"
        if File.exist?("#{dir}/.git")
          system "cd  #{dir}; git log --author=#{ENV['USER']} --oneline --after=#{today} --before=#{tomorrow}| cut -d ' ' -f 2-"
        end
      end
    end
    puts "----------------------------------"
    ask 'Remark'
  end


  def project_chooser(form)
    puts 'Recently used projects'
    form.list_recent_projects
    puts "     0 - Other"
    answer = ask "Project ID"
    case answer
    when ''
      warn "TODO Not implementd"
      exit 1
    when '0'
      return all_projects_chooser(form)
    else
      return answer
    end
  end


  def all_projects_chooser(form)
    form.list_all_projects
    answer = ask
  end


  def login
    load_cookies

    page = @agent.get(RC[:url])

    return if page.forms.empty?

    puts "Logging in"

    form = page.forms.first
    form.auth_user = RC[:user]
    form.auth_pw   = RC[:password]
    page = @agent.submit(form, form.buttons.first)

    @agent.cookie_jar.save_as("#{ENV['HOME']}/.achoo_cookies.yml")

    # FIX check login failure
    #  - "Username and/or password are incorrect. Please try again."
    #  - page.forms.empty?
  end


  def load_cookies
    cookies_file = "#{ENV['HOME']}/.achoo_cookies.yml"
    FileUtils.touch(cookies_file)
    @agent.cookie_jar.load(cookies_file)
  end


  def print_welcome
    puts "Welcome to Achoo!"
  end


  def date_chooser
    answer = ask "Date [today]"
    date = case answer
           when ''
             Date.today
           else
             Date.parse(answer)
           end
    return date
  end


  def ask(question='')
    print bold("#{question}> ")
    answer = gets.chop
    unless $stdin.tty?
      puts answer
    end
    answer
  end


  def bold(text)
    "\e[1m#{text}\e[0m"
  end

end
