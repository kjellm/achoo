require 'achoo/ui/date_chooser'

module Achoo
  module UI
    class OptionallyRangedDateChooser < DateChooser

      def parse_date_range(date_range_str)
        start_date_str, finish_date_str = *date_range_str.split('->')
        start_date = parse_date(start_date_str.strip)
        finish_date = parse_date(finish_date_str.strip, start_date)
        
        if start_date >= finish_date
          raise ArgumentError.new('Invalid date range')
        end
        
        [start_date, finish_date]
      end

      private 
      
      def handle_answer(answer)
        if answer.include? '->'
          return parse_date_range(answer)
        else 
          return super
        end
      end
      
      def date_format_help_string
        return "    DATE [-> DATE]\n" \
            << "    DATE:\n"          \
            << FORMAT
      end

    end
  end
end
