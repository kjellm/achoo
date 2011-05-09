require 'achoo'
require 'achoo/ical'

module Achoo
  class Plugin
    class Ical < Achoo::Plugin
      
      def at_startup
        warm_up_ical_cache
      end

      def before_register_hour_remark
        date = Date.today
        puts "Calendar events for #{date}:"
        puts '---'
        begin
          RC[:ical].each do |config|
            ICal.from_http_request(config).print_events(date)
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
              ICal.from_http_request(config)
            rescue Exception => e
              puts "Failed to fetch calendar data: #{e}"
            end
          end
        end
      end
      
    end
  end
end
