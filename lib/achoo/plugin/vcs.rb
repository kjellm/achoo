require 'achoo'
require 'achoo/vcs'
require 'achoo/ui'

module Achoo
  class Plugin
    class VCS < Achoo::Plugin

      include UI::ExceptionHandling
      
      def state_ok?; RC.has_key?(:vcs); end
      
      def before_register_hour_remark(date)
        puts '-' * 80
        puts "VCS logs for #{date}:"
        begin
          Achoo::VCS.print_logs_for(date, RC[:vcs_dirs])
        rescue Exception => e
          puts handle_exception("Failed to retrieve VCS logs.", e)
        end
      end
      
    end
  end
end
