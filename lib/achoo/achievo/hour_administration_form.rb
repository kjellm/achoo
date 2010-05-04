require 'achoo/achievo'
require 'achoo/term/table'

module Achoo
  module Achievo
    class HourAdministrationForm

      include Achievo::DateField('date', 'viewdate')

      def initialize(agent)
        @agent = agent
        @page  = nil
      end

      def show_registered_hours_for_day(date)
        show_registered_hours(date, 'dayview', '#rl_1 tr')
      end
  
      def show_registered_hours_for_week(date)
        show_registered_hours(date, 'weekview', '//form[@name="weekview"]/following::table/tr')
      end

      def flexi_time(date)
        set_page_to_view_for_date('dayview', date)
        
        @page.body.match(/Flexi time balance: (-?\d+:\d+)/)[1]
      end

      private
  
      def show_registered_hours(date, view, query)
        set_page_to_view_for_date(view, date)
        
        table = Table.new(@page.search(query))

        if view == 'weekview'
          table.first.each {|c| c.gsub!(/\s+/, ' ') }
        end

        if view == 'dayview'
          table.select_columns do |c|
            # '' -> Ruby 1.9, ' ' -> Ruby 1.8
            !['', ' ', 'Billing billed', 'Billing marked', 'Billing total'].include?(c[0])

          end
        end

        summaries = table.length > 1 ? table.last : nil

        Term::Table.new(table.first,
                        table[1 .. table.length-2], 
                        summaries).print
      end
  
      def set_page_to_view_for_date(view, date)
        @page ||= @agent.get(RC[:hour_admin_url])
        
        link = @page.link_with(:text => view.capitalize)
        @form = @page.form(view)
        unless link.nil?
          puts "Fetching #{view} ..."
          @page = link.click
          @form = @page.form(view)
        end
        unless date == self.date
          @page = get_page_for(date)
          @form = @page.form(view)
        end

        @page
      end    

      def get_page_for(date)
        puts "Fetching data for #{date} ..."
        self.date = date
        @page = @form.submit
      end
      
    end  
  end
end
