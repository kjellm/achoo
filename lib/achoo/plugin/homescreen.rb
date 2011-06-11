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

      def before_print_menu(date)
        form = Achievo::HourAdministrationForm.new
        Term::clearscreen

        case RC[:homescreen]
        when 'day'
          form.show_registered_hours_for_day(date)
        when 'week'
          form.show_registered_hours_for_week(date)
        else
          printf "Unknown homescreen '%s', ignoring\n", RC['homescreen']
        end
      end
    end
  end
end
