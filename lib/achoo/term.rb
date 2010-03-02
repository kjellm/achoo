if RUBY_VERSION < "1.9"
  $KCODE = 'u'
  require 'jcode'
end

class Achoo; end

class Achoo::Term

  def self.bold(text); "\e[1m#{text}\e[0m"; end

  def self.underline(text); "\e[4m#{text}\e[0m"; end

  def self.warn(text); "\e[1;33m#{text}\e[0m"; end

  def self.fatal(text); "\e[1;31m#{text}\e[0m"; end

  def self.password
    `stty -echo`
    pas = ask('Password')
    `stty echo`
    pas
  end

  def self.ask(question='')
    answer = nil
    loop do
      print bold("#{question}> ")
      $stdout.flush
      answer = gets
      
      # Answer is nil if user hits C-d
      answer.chop! unless answer.nil?

      unless $stdin.tty?
        puts answer
      end
      break unless a_little_something(answer)
    end
    answer
  end

  def self.menu(question, entries, special=nil, additional_valid_answers=[])
    print_menu(entries, special)
    return '1' if entries.length == 1 && special.nil?

    valid_answers = {}
    valid_answers['0'] = true unless special.nil?
    1.upto(entries.length).each {|i| valid_answers[i.to_s] = true}
    additional_valid_answers.each {|a| valid_answers[a] = true}

    answer = nil
    while true
      answer = ask question
      if valid_answers[answer]
        break
      else
        puts "Invalid value. Must be one of " << valid_answers.keys.sort.join(',')
      end
    end

    answer
  end

  private

  def self.print_menu(entries, special)
    max_digits = Math.log10(entries.length).to_i
    format = "% #{max_digits}d. %s\n"
    entries.each_with_index do |entry, i|
      printf format, i+1, entry
    end
    printf format, 0, special unless special.nil?
  end

  def self.a_little_something(answer)
    return false if answer.nil?

    case answer.downcase
    when 'bless you!', 'gesundheit!'
      puts "Thank you!"
      return true
    else
      return false
    end
  end

end
