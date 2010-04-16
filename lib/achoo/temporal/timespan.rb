require 'achoo/temporal'
require 'time'

class Achoo::Temporal::Timespan

  SECONDS_IN_A_DAY    = 86400
  SECONDS_IN_AN_HOUR  = 3600
  SECONDS_IN_A_MINUTE = 60

  attr :start
  attr :end

  def initialize(start, end_)
    raise ArgumentError.new('Nil in parameters not allowed') if start.nil? || end_.nil?

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
    if timeish_or_timespan.is_a? Achoo::Temporal::Timespan
      timespan = timeish_or_timespan
      return start <= timespan.start && self.end >= timespan.end
    else
      time = to_time(timeish_or_timespan)
      return start <= time && self.end >= time
    end
  end

  def overlaps?(timespan)
    start <= timespan.start && self.end >= timespan.start \
      || start <= timespan.end && self.end >= timespan.end \
      || contains?(timespan) || timespan.contains?(self)
  end

  private 
  
  def to_time(timeish)
    case timeish
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
    today      = Date.today
    start_date = start.send(:to_date)
    end_date   = self.end.send(:to_date)

    format = if start_date == today
               "Today"
             elsif start_date.month == today.month && 
                 start_date.year == today.year
               "%a %e."
             elsif start_date.year == today.year
               "%a %e. %b"
             else
               "%a %e. %b %Y"
             end
    from = start.strftime(format << " %R")

    format = if end_date == start_date
               "%R"
             elsif end_date == today
               "Today %R"
             elsif end_date.month == today.month && 
               end_date.year == today.year
               "%a %e. %R"
             elsif end_date.year == today.year
               "%a %e. %b %R"
             else
               "%a %e. %b %Y %R"
             end
    to = self.end.strftime(format)

    sprintf "%s - %s", from, to
  end

end
