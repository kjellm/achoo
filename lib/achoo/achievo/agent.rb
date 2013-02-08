require 'delegate'
require 'mechanize'

module Achoo
  module Achievo
    class Agent < DelegateClass(Mechanize)

      def initialize(url, user, log=nil)
        super(Mechanize.new)
        self.log = log
        @url  = url
        @user = user
        @urls = {}
      end

      def start
        login_with_cookies
        scrape_urls
      end

      def get_hour_registration
        get(@urls[:hour_registration])
      end

      def get_hour_administration
        get_hour_registration
      end

      def get_time_survey
        get(@urls[:time_survey])
      end

      def get_holiday_report
        get(@urls[:holiday_report])
      end

      def get_lock_months
        get(@urls[:lock_months])
      end

      private

      def scrape_urls 
        page = get(current_page.frames.find {|f| f.name == 'menu'}.href)
        menu_links = page.search('a.menuItemLevel2')
        
        @urls[:hour_registration] = menu_link_to_url(menu_links, 'Time Registration')
        @urls[:lock_months]       = menu_link_to_url(menu_links, 'Lock months')
        @urls[:holiday_report]    = menu_link_to_url(menu_links, 'Holiday report')
        @urls[:time_survey]       = menu_link_to_url(menu_links, 'Time Survey')
      end

      def login_with_cookies
        load_cookies
        login
        save_cookies
      end

      def login
        puts "Fetching data ..."
        page = get(@url)

        return if page.forms.empty? # already logged in

        puts "Logging in ..."

        form = page.forms.first
        form.auth_user = @user.name
        form.auth_pw   = @user.password
        page = submit(form, form.buttons.first)

        if page.body.match(/Username and\/or password are incorrect. Please try again./)
          raise "Username and/or password are incorrect."
        end
      end

      def cookies_file; "#{ENV['HOME']}/.achoo_cookies.txt"; end
      
      def cookies_file_format; :cookiestxt; end

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



      def load_cookies
        return unless FileTest.exists? cookies_file
        cookie_jar.load(cookies_file, cookies_file_format)
      end


      def save_cookies
        cookie_jar.save_as(cookies_file, cookies_file_format)
      end

    end
  end
end
