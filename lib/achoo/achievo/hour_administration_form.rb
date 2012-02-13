require 'achoo/achievo'
require 'shellout'

module Achoo
  module Achievo
    class HourAdministrationForm

      include Achievo::DateField('date', 'viewdate')
      include Shellout

      def initialize
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

        table.first.each {|c| c.gsub!(/[\u00A0\s]+/, ' ') }

        if view == 'dayview'
          table.select_columns do |c|
            p c[0]
            ![' ', 'Billing billed', 'Billing marked', 'Billing total'].include?(c[0])

          end
        end

        table_params = {
          headers: table.first,
          rows:    table[1 .. table.length-2],
        }
        table_params[:footers] = table.last if table.length > 1
        Table(table_params).print
      end
  
      def set_page_to_view_for_date(view, date)
        @page ||= AGENT.get_hour_administration
        
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
