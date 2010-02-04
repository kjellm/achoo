require 'achoo/date_time_interval'

class Achoo
  class Last
    
    FILE_BOUNDARY_MARKER = "---"

    def initialize
    end

    def find_by_date(date)
      intervals.find do |i| 
        if i.start.strftime('%Y-%m-%d') == date.strftime('%Y-%m-%d')
          puts i
        end
      end
    end

    private

    def intervals
      process_last_logs unless @intervals 
      @intervals
    end

    # wtmp file boundaries needs to be handled specially.
    def process_last_logs
      output = []
      wtmp = Dir.glob('/var/log/wtmp*').sort
      wtmp.each do |f|
        output.concat(%x{last -RF -f #{f} reboot}.split("\n"))
        output << FILE_BOUNDARY_MARKER
      end
      

      @intervals = []
      merge_next = false
      output.each do |line|
        interval = nil
        if line.match(/^reboot\s+system\sboot\s+(.*?)\s+\(/)
          $1 =~ /(.*) - (.*)/
          interval = Achoo::DateTimeInterval.new
          interval.start = $1
          interval.end   = $2
        else
          if line == FILE_BOUNDARY_MARKER
            merge_next = true
          end
          next
        end

        if merge_next
          @intervals.last.start = interval.start
          merge_next = false
        else
          @intervals << interval
        end
      end
    end
  end
end
