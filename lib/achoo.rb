class Achoo; end

require 'achoo/term'
require 'achoo/ui'
require 'logger'
require 'mechanize'



class Achoo

  include Achoo::UI::Commands
  include Achoo::UI::ExceptionHandling
  include Achoo::UI::RegisterHours
  
  def initialize(log=false)
    @agent = Mechanize.new
    if log
      @agent.log = Logger.new("achoo_http.log")
    end
  end

  def start
    begin
      print_welcome
      login
      scrape_urls
      command_loop
    rescue SystemExit => e
      raise
    rescue Exception => e
      handle_fatal_exception("Something bad happened. Shutting down.", e)
    end
  end


  def print_welcome
    puts "Welcome to Achoo!"
  end


  def command_loop
    while true
      answer = Term.choose('[1]',
                           ["Register hours",
                            "Show flexitime balance",
                            "Day hour report",
                            "Week hour report",
                            "Holiday balance",
                            "Lock month",
                           ],
                           "Exit",
                           ['q', 'Q', ''])
      dispatch(answer)
    end
  end

  
  def dispatch(command)
      case command
      when '0', 'q', 'Q'
        exit
      when '1', ''
        register_hours(@agent)
      when '2'
        show_flexi_time(@agent)
      when '3'
        show_registered_hours_for_day(@agent)
      when '4'
        show_registered_hours_for_week(@agent)
      when '5'
        show_holiday_report(@agent)
      when '6'
        lock_month(@agent)
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
    a_tag = menu_links.find {|a| 
      a.text.strip == text
    }
    
    if a_tag.nil?
      raise Exception.new("Could not find the '#{text}' link in Achievo.\nMake sure that language is 'English' and theme is 'no value' in Achievo's user preferences.\nYou must delete ~/.achoo_cookies.yml for these changes to take affect.")
    end

    url = a_tag.attribute('onclick').value.match(/window\.open\('([^']+)/)[1]
    return "#{RC[:url]}#{url}"
  end


  def login
    load_cookies

    puts "Fetching data ..."
    page = @agent.get(RC[:url])

    return if page.forms.empty?

    puts "Logging in ..."

    form = page.forms.first
    form.auth_user = RC[:user]
    form.auth_pw   = RC[:password]
    page = @agent.submit(form, form.buttons.first)

    if page.body.match(/Username and\/or password are incorrect. Please try again./)
      raise "Username and/or password are incorrect."
    end

    @agent.cookie_jar.save_as("#{ENV['HOME']}/.achoo_cookies.yml")
  end


  def load_cookies
    cookies_file = "#{ENV['HOME']}/.achoo_cookies.yml"
    if FileTest.exists? cookies_file
      @agent.cookie_jar.load(cookies_file)
    end
  end


end

