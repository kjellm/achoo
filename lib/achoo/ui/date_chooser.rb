require 'achoo/term'

class Achoo; class UI; end; end

module Achoo::UI::DateChooser

  def date_chooser
    loop do
      answer = Achoo::Term::ask "Date ([today] | ?)"
      case answer
      when '?'
        puts "Accepted formats:"
        puts "\t today | (+|-)n | [[[YY]YY]-[M]M]-[D]D"
        puts
        system 'cal -3m'
      when '', 'today'
        return Date.today
      else
        begin
          return parse_date(answer)
        rescue ArgumentError => e
          puts e.message
        end
      end
    end
  end

  def parse_date(date_str)
    today = Date.today
    case date_str.chars.first
    when '-'
      return today - date_str[1..-1].to_i
    when '+'
      return today + date_str[1..-1].to_i
    end
    
    date = date_str.split('-').collect {|d| d.to_i}
    case date.length
    when 1
      return Date.civil(today.year, today.month, *date)
    when 2
      return Date.civil(today.year, *date)
    when 3
      date[0] += 2000 if date[0] < 100
      return Date.civil(*date)
    end
  end

end
