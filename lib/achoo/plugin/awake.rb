require 'achoo/awake'
require 'achoo/ui'

module Achoo
  class Plugin
    class Awake < Plugman::PluginBase

      include UI::ExceptionHandling

      def before_register_hour_hours(date)
        puts "Awake log:"
        begin
          awake = Achoo::Awake.new
          awake.at(date)
          puts
        rescue Exception => e
          print handle_exception("Failed to retrieve awake log.", e)
        end
      end
      
    end
  end
end
