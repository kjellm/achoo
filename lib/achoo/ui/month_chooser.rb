require 'achoo/term'
require 'achoo/ui'

module Achoo
  module UI
    class MonthChooser

      def choose
        loop do
          answer = Term::ask "Period ([#{one_month_ago}] | YYYYMM)"
          begin
            return handle_answer(answer)
          rescue ArgumentError => e
            puts e
          end
        end
      end

      def handle_answer(answer)
        period = !answer || answer.empty? ? one_month_ago : answer
        period =~ /\A \d{4} (?: 0\d | 1[0-2]) \z/x \
        or raise ArgumentError.new('Invalid month')
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

    end
  end
end

