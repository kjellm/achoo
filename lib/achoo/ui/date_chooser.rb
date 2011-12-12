require 'achoo/term'
require 'achoo/ui'
require 'shellout'

module Achoo
  module UI

    class DateChooser

      include Shellout

      PROMPT = "Date ([today] | ?)"
      FORMAT = "        today | (+|-)n | [[[YY]YY]-[M]M]-[D]D"

      def choose
        loop do
          answer = Term::ask PROMPT 
          begin
            date = handle_answer(answer)
            return date if date
          rescue ArgumentError => e
            puts e
          end
        end
      end
      
      def parse_date(date_str, base=Date.today)
        raise ArgumentError.new('Invalid date') if date_str.nil?
        
        # Today (default)
        if date_str == 'today' || date_str.empty?
          return Date.today
        end
        
        # Base offset
        case date_str.chars.first
        when '-'
          return base - Integer(date_str[1..-1])
        when '+'
          return base + Integer(date_str[1..-1])
        end
        
        # 
        date = date_str.split('-').collect {|d| d.to_i}
        case date.length
        when 1
          return Date.civil(base.year, base.month, *date)
        when 2
          return Date.civil(base.year, *date)
        when 3
          date[0] += 2000 if date[0] < 100
          return Date.civil(*date)
        end
        
        raise ArgumentError.new('Invalid date')
      end
      
      private
      
      def handle_answer(answer)
        if answer == '?'
          print_help_message
          return false
        else
          return parse_date(answer)
        end
      end
      
      def print_help_message   
        puts "Accepted formats:"
        puts date_format_help_string
        puts
        Calendar().print3
      end
      
      def date_format_help_string
        FORMAT
      end

    end
  end
end
