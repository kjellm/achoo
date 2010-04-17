require 'achoo/term'

class Achoo::Term::Menu

  def initialize(question, entries, special=nil, additional_valid_answers=[])
    @question = question
    @entries  = entries
    @special  = special

    @valid = {}
    @valid['0'] = true unless @special.nil?
    1.upto(@entries.length).each {|i| @valid[i.to_s] = true}
    additional_valid_answers.each {|a| @valid[a] = true}
  end

  def print_ask_and_validate()
    return nil if @entries.empty?

    print_menu()
    return '1' if only_one_option?
    
    loop do
      answer = Achoo::Term.ask(@question)
      if @valid[answer]
        return answer
      else
        puts "Invalid value. Must be one of " << @valid.keys.sort.join(',')
      end
    end
  end
  
  private

  def print_menu
    format = menu_item_format
    @entries.each_with_index do |entry, i|
      printf format, i+1, entry
    end
    printf format, 0, @special unless @special.nil?
  end

  def only_one_option?
    @entries.length == 1 && @special.nil?
  end
  
  def menu_item_format
    max_digits = Math.log10(@entries.length).floor + 1
    " %#{max_digits}d. %s\n"
  end

end
