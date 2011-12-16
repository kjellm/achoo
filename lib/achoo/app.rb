require 'achoo'
require 'achoo/achievo'
require 'achoo/term'
require 'achoo/ui'
require 'logger'
require 'mechanize'
require 'plugman'
require 'plugman/finder'

require 'shellout'
require 'shellout/command_loop'
require 'shellout/menu_query'

module Achoo

  AGENT   = Mechanize.new
  PLUGINS = Plugman.new('achoo')

  class App

    include UI::Commands
    include UI::ExceptionHandling
    include UI::RegisterHours
    
    include Shellout

    COOKIES_FILE = "#{ENV['HOME']}/.achoo_cookies.txt"
    

    def initialize(log=false)
      @last_used_date = Date.today
      if log
        AGENT.log = Logger.new("achoo_http.log")
      end
    end


    def start
      begin
        PLUGINS.load_plugins
        puts PLUGINS.log if ENV['ACHOO_DEBUG']
        PLUGINS.signal_at_startup
        print_welcome
        login
        scrape_urls
        #print_homescreen
        command_loop
      rescue SystemExit => e
        raise
      rescue Exception => e
        handle_fatal_exception("Something bad happened. Shutting down.", e)
      end
    end


    private


    def print_welcome
      Shadowbox("Welcome to Achoo!").print
    end


    def command_loop
      main_menu_items = {
        "Register hours" => ->{
          date = register_hours
          @last_used_date = date.class == Array ? date.first : date
        },
        "Show flexitime balance" => ->{show_flexi_time},
        "Day hour report"        => ->{show_registered_hours_for_day},
        "Week hour report"       => ->{show_registered_hours_for_week},
        "Holiday balance"        => ->{show_holiday_report},
        "Lock month"             => ->{lock_month},
        "Exit"                   => ->{ exit }
      }
      main_menu = MenuQuery.new(main_menu_items, true)
      # FIXME put next two lines inside command loop
      PLUGINS.signal_before_print_menu(@last_used_date)
      @last_used_date = Date.today
      Shellout::CommandLoop.new(main_menu).call
      # FIXME
      # choices << "Time survey report" if RC[:reports]
      # ['q', 'Q', ''])
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
      if FileTest.exists? COOKIES_FILE
        AGENT.cookie_jar.load(COOKIES_FILE, :cookiestxt)
      end
    end


    def save_cookies
      AGENT.cookie_jar.save_as(COOKIES_FILE, :cookiestxt)
    end

  end
end

