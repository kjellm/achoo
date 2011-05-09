require 'achoo'
require 'achoo/achievo'
require 'achoo/plugin_manager'
require 'achoo/term'
require 'achoo/ui'
require 'logger'
require 'mechanize'

module Achoo

  AGENT = Mechanize.new

  class App

    include UI::Commands
    include UI::ExceptionHandling
    include UI::RegisterHours
    

    def initialize(log=false)
      if log
        AGENT.log = Logger.new("achoo_http.log")
      end
      @plugin_manager = PluginManager.instance
    end


    def start
      begin
        @plugin_manager.load_plugins
        print_welcome
        @plugin_manager.send_at_startup
        login
        scrape_urls
        print_homescreen
        command_loop
      rescue SystemExit => e
        raise
      rescue Exception => e
        handle_fatal_exception("Something bad happened. Shutting down.", e)
      end
    end


    private


    def print_welcome
      puts Term.shadowbox("Welcome to Achoo!")
    end


    def command_loop
      while true
        begin
          trap("INT", "DEFAULT");
          choices = ["Register hours",
                     "Show flexitime balance",
                     "Day hour report",
                     "Week hour report",
                     "Holiday balance",
                     "Lock month",
                    ]
          choices << "Time survey report" if RC[:reports]
          answer = Term.choose('[1]',
                               choices,
                               "Exit",
                               ['q', 'Q', ''])
          dispatch(answer)
        rescue Interrupt
          puts # Add a new line in case we are prompting
          print_homescreen
        end
      end
    end

    
    def dispatch(command)
      case command
      when '0', 'q', 'Q'
        exit
      when '1', ''
        date = register_hours
        if (date.class == Array)
          # For date range, pick the first date
          date = date[0]
        end
        print_homescreen(date)
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
      when '7'
        view_report
      end
    end

    def print_homescreen(date = Date.today)
      if RC[:homescreen] == nil
        return
      end

      Term::clearscreen

      case RC[:homescreen]
      when 'day'
        form = Achievo::HourAdministrationForm.new
        form.show_registered_hours_for_day(date)
      when 'week'
        form = Achievo::HourAdministrationForm.new
        form.show_registered_hours_for_week(date)
      else
        printf "Unknown homescreen '%s', ignoring\n", RC['homescreen']
      end
    end

    def scrape_urls 
      page = AGENT.get(AGENT.current_page.frames.find {|f| f.name == 'menu'}.href)
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
      Achievo::LoginForm.login
      save_cookies
    end


    def load_cookies
      cookies_file = "#{ENV['HOME']}/.achoo_cookies.yml"
      if FileTest.exists? cookies_file
        AGENT.cookie_jar.load(cookies_file)
      end
    end


    def save_cookies
      AGENT.cookie_jar.save_as("#{ENV['HOME']}/.achoo_cookies.yml")
    end

  end
end

