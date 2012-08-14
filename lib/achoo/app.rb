require 'achoo'
require 'achoo/achievo'
require 'achoo/term'
require 'achoo/ui'
require 'logger'
require 'mechanize'
require 'ostruct'
require 'plugman'
require 'shellout'

module Achoo

  class App

    include UI::Commands
    include UI::ExceptionHandling
    include UI::RegisterHours
    
    include Shellout

    def initialize(log=false)
      @last_used_date = Date.today
      if log
        AGENT.log = Logger.new("achoo_http.log")
      end
    end


    def start
      begin
        Achoo.const_set(:PLUGINS, Plugman.new(
              logger: Logger.new(STDERR), 
              loader: Plugman::ConfigLoader.new(RC[:plugins]),
              ))

        PLUGINS.load_plugins
        PLUGINS.notify :at_startup
        print_welcome
        Achoo.const_set(:AGENT, 
          Achievo::Agent.new(
            RC[:url],
            OpenStruct.new({name: RC[:user], password: RC[:password]})))
        #print_homescreen
        command_loop
      rescue SystemExit => e
        raise
      rescue Exception => e
        handle_fatal_exception("Something bad happened. Shutting down.", e)
      end
    end


    private


    def print_welcome
      Shadowbox("Welcome to Achoo!").print
    end


    def command_loop
      while true
        begin
          trap("INT", "DEFAULT");
          PLUGINS.notify :before_print_menu, @last_used_date
          @last_used_date = Date.today
          choices = ["Register hours",
                     "Show flexitime balance",
                     "Day hour report",
                     "Week hour report",
                     "Holiday balance",
                     "Lock month",
                    ]
          choices << "Time survey report" if RC[:reports]
          answer = Term.choose('[1]',
                               choices,
                               "Exit",
                               ['q', 'Q', ''])
          dispatch(answer)
        rescue Interrupt
          puts # Add a new line in case we are prompting
        end
      end
    end

    
    def dispatch(command)
      case command
      when '0', 'q', 'Q'
        exit
      when '1', ''
        date = register_hours
        @last_used_date = date.class == Array ? date.first : date
      when '2'
        show_flexi_time
      when '3'
        show_registered_hours_for_day
      when '4'
        show_registered_hours_for_week
      when '5'
        show_holiday_report
      when '6'
        lock_month
      when '7'
        view_report
      end
    end


  end
end

