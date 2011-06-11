require 'achoo'
require 'achoo/plugin_base'
require 'achoo/ui'
require 'achoo/vcs'

module Achoo
  class Plugin
    class VCS < PluginBase

      include UI::ExceptionHandling
      
      def state_ok?; RC.has_key?(:vcs_dirs) && !RC[:vcs_dirs].empty?; end
      
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
