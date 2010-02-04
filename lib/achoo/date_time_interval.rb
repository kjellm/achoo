require 'parsedate'

class Achoo
  class DateTimeInterval
    attr :start
    attr :end

    def start=(date_time)
      date_time = Time.local(*ParseDate.parsedate(date_time)) if date_time.kind_of?(String)
      @start = date_time
    end
    
    def end=(date_time)
      date_time = Time.local(*ParseDate.parsedate(date_time)) if date_time.kind_of?(String)
      @end = date_time
    end

    def to_s
      delta = @end - @start

      d = delta.to_i / (86400)
      delta = delta - d*(86400)
      h = delta.to_i / (3600)
      delta = delta - h*(3600)
      m = delta.to_i / (60)

      sprintf "%s - %s (%d+%02d:%02d)", start, self.end, d, h, m
    end
    
  end
end
