require 'achoo/system'

module Achoo
  module System

    class LogEntry 
      include Comparable
    
      attr :time
      attr :event
    
      def initialize(time, event)
        @time  = time
        @event = event
      end
      
      def <=>(other_entry)
        time <=> other_entry.time
      end
    end

  end
end

