require 'achoo'
require 'achoo/ui'
require 'plugman/plugin_base'

module Achoo
  class Plugin
    class Homescreen < Plugman::PluginBase

      include UI::ExceptionHandling

      def state_ok?; RC.has_key?(:homescreen); end

      def at_startup
        Term::clearscreen
      end

      def print_homescreen(date = Date.today)
        Term::clearscreen

        case RC[:homescreen]
        when 'day'
          form = Achievo::HourAdministrationForm.new
          form.show_registered_hours_for_day(date)
        when 'week'
          form = Achievo::HourAdministrationForm.new
          form.show_registered_hours_for_week(date)
        else
          printf "Unknown homescreen '%s', ignoring\n", RC['homescreen']
        end
      end
    end
  end
end
