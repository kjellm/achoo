# encoding: utf-8

require 'achoo'
require 'readline'

module Achoo
  class Term

    autoload :Menu,  'achoo/term/menu'
    autoload :Table, 'achoo/term/table'

    BOLD      = 1
    UNDERLINE = 4
    RED       = 31
    YELLOW    = 33

    def self.effect(code, text); "\e[#{code}m#{text}\e[0m"; end

    def self.bold(text);      effect(BOLD,      text); end
    def self.underline(text); effect(UNDERLINE, text); end
    def self.warn(text);      effect(YELLOW,    text); end
    def self.fatal(text);     effect(RED,       text); end

    def self.clearscreen
      print "\e[2J\e[H"
      $stdout.flush
    end

    def self.password
      `stty -echo`
      pas = ask('Password')
      `stty echo`
      pas
    end

    def self.ask(question='')
      answer = Readline.readline(bold("#{question}> "), true)
        
      # Answer is nil if user hits C-d on an empty input
      if answer.nil?
        puts
        exit
      end
      
      answer.strip
    end

    def self.choose(question, entries, special=nil, additional_valid_answers=[])
      menu = Menu.new(question, entries, special, additional_valid_answers)
      menu.print_ask_and_validate
    end
  end

end
