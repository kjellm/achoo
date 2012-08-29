require 'achoo'
require 'achoo/ical'
require 'achoo/plugin_base'
require 'achoo/ui'

module Achoo
  class Plugin
    class Ical < PluginBase

      include UI::ExceptionHandling

      def state_ok?; RC.has_key?(:ical) && !RC[:ical].empty?; end
      
      def at_startup
        warm_up_ical_cache
      end

      def before_register_hour_remark(date)
        puts '-' * 80
        puts "Calendar events for #{date}:"
        puts '---'
        begin
          RC[:ical].each do |config|
            Achoo::ICal.from_http_request(config).print_events(date)
          end
        rescue Exception => e
          puts handle_exception("Failed to retrieve calendar events.", e)
        end
      end

      private

      def warm_up_ical_cache
        Thread.new do 
          RC[:ical].each do |config|
            begin
              Achoo::ICal.from_http_request(config)
            rescue Exception => e
              puts handle_exception("Failed to fetch calendar data.", e)
            end
          end
        end
      end
      
    end
  end
end
