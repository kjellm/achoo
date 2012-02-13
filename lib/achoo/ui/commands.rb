require 'achoo/achievo'
require 'achoo/term'
require 'achoo/ui'
require 'shellout/table'

module Achoo
  module UI
    module Commands

      include DateChoosers
      include Common

      def show_registered_hours_for_day
        date = date_chooser
        form = Achievo::HourAdministrationForm.new
        form.show_registered_hours_for_day(date)
      end

      def show_registered_hours_for_week
        date = date_chooser
        form = Achievo::HourAdministrationForm.new
        form.show_registered_hours_for_week(date)
      end


      def show_flexi_time
        date = date_chooser
        form = Achievo::HourAdministrationForm.new
        balance = form.flexi_time(date)
        puts "Flexi time balance: #{Term::underline(balance)}"
      end


      def lock_month
        month = month_chooser
        form  = Achievo::LockMonthForm.new
        form.lock_month(month)
        form.print_values
        if confirm
          form.submit
        else
          puts "Cancelled"
        end
      end

  
      def show_holiday_report
        page = AGENT.get_holiday_report
        page.body.match(/<b>(\d+,\d+)<\/b>/)
        puts "Balance: #{Term::underline($1)}"
      end

      
      def view_report
        choices = RC[:reports].keys
        answer = Term.choose('Report', choices)
        key = choices[answer.to_i - 1]
        
        puts "Fetching data ..."
        page = AGENT.get(RC[:url] + RC[:reports][key])
        
        table = Achievo::Table.new(page.search('#rl_1 tr'))
        table.select_columns do |c|
          ['Date', 'Project', 'Phase', 'Remark', 'Time'].include?(c[0])
        end
        
        Shellout::Table.new(headers: table.first,
                            rows:    table[2...table.length-1],
                            footers: table.last).print
      end
      
    end
  end
end
