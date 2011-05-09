require 'achoo/achievo'

module Achoo
  module Achievo
    class LockMonthForm

      def lock_month(period)
        page  = AGENT.get(RC[:lock_months_url])
        @form  = page.form('entryform')

        @form.period = period
        unless user_select.nil?
          user_select.options.each do |opt|
            if opt.text.match(/\(#{RC[:user]}\)$/)
              opt.select
            end
          end
        end

      end

      def print_values
        puts "Month: #{@form.period}"
        puts " User: #{user_select.value}" unless user_select.nil?

      end
      
      def submit
        @form.submit
      end

      private

      def user_select
        @form.field_with(:name => 'userid')
      end
      
    end
  end
end
