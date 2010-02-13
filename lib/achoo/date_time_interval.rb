require 'parsedate'

class Achoo; end

class Achoo::DateTimeInterval

  SECONDS_IN_DAY    = 86400
  SECONDS_IN_HOUR   = 3600
  SECONDS_IN_MINUTE = 60

  attr :start
  attr :end

  def initialize(start_dt=nil, end_dt=nil)
    self.start = start_dt
    self.end   = end_dt
  end

  def start=(date_time)
    date_time = Time.local(*ParseDate.parsedate(date_time)) if date_time.kind_of?(String)
    @start = date_time
  end
  
  def end=(date_time)
    date_time = Time.local(*ParseDate.parsedate(date_time)) if date_time.kind_of?(String)
    @end = date_time
  end

  def to_s
    duration = duration_string
    from_to  = from_to_string

    sprintf("(%s) %s", duration, from_to)
  end

  def contains(date)
    start = self.start.strftime("%F")
    stop  = self.end.strftime("%F")
    date = date.strftime("%F")
    return start <= date && stop >= date
  end

  def contains_interval(dt_interval)
    #puts "### #{self}"
    #puts "!!! #{dt_interval}"
    test = (self.start <=> dt_interval.start) <= 0 \
      && (self.end <=> dt_interval.end) >= 0
    #puts "=== #{test}"
    return test
  end

  private 
  
  def duration_string
    delta = @end - @start
    d     = delta.to_i / SECONDS_IN_DAY

    delta = delta - d*SECONDS_IN_DAY
    h     = delta.to_i / SECONDS_IN_HOUR

    delta = delta - h*SECONDS_IN_HOUR
    m     = delta.to_i / SECONDS_IN_MINUTE

    sprintf "%d+%02d:%02d", d, h, m
  end

  def from_to_string
    # FIX 
    #  - Don't print month if same as today's month
    #  - Don't print year if same as today's year
    #  - Etc

    from = nil
    if start.send(:to_date) == Date.today
      from = start.strftime("Today %R")
    else
      from = start.strftime("%a %e. %b %Y %R")
    end
    
    to = nil
    if self.end.send(:to_date) == start.send(:to_date)
      to = self.end.strftime("%R")
    elsif self.end.send(:to_date) == Date.today
      to = self.end.strftime("Today %R")
    else
      to = self.end.strftime("%a %e. %b %Y %R")
    end

    sprintf "%s - %s", from, to
  end

end
