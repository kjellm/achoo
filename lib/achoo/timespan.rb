require 'time'

class Achoo; end

class Achoo::Timespan

  SECONDS_IN_A_DAY    = 86400
  SECONDS_IN_AN_HOUR  = 3600
  SECONDS_IN_A_MINUTE = 60

  attr :start
  attr :end

  def initialize(start, end_)
    self.start = start
    self.end   = end_
  end

  def start=(timeish)
    @start = to_time(timeish)
  end
  
  def end=(timeish)
    @end = to_time(timeish)
  end

  def to_s
    duration = duration_string
    from_to  = from_to_string

    sprintf("(%s) %s", duration, from_to)
  end

  def contains?(timeish_or_timespan)
    if timeish_or_timespan.instance_of? self.class
      timespan = timeish_or_timespan
      return start <= timespan.start && self.end >= timespan.end
    else
      time = to_time(timeish_or_timespan)
      return start <= time && self.end >= time
    end
  end

  private 
  
  def to_time(timeish)
    case timeish.class
    when Time
      timeish.clone
    when DateTime
      Time.local(timeish.year, timeish.month, timeish.day, timeish.hour,timeish.minute, timeish.second)
    when Date
      Time.local(timeish.year, timeish.month, timeish.day)
    else
      if timeish.respond_to?(:to_s)
        Time.parse(timeish.to_s)
      else
        raise ArgumentError.new("Don't know how to convert #{timeish.class} to Time")
      end
    end
  end


  def duration_string
    delta = @end - @start
    d     = delta.to_i / SECONDS_IN_A_DAY

    delta = delta - d*SECONDS_IN_A_DAY
    h     = delta.to_i / SECONDS_IN_AN_HOUR

    delta = delta - h*SECONDS_IN_AN_HOUR
    m     = delta.to_i / SECONDS_IN_A_MINUTE

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
