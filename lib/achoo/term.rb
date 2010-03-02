require 'achoo/term/menu'
require 'achoo/term/table'

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

  def self.choose(question, entries, special=nil, additional_valid_answers=[])
    menu = Achoo::Term::Menu.new(question, entries, special, additional_valid_answers)
    menu.print_ask_and_validate
  end

  private

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
