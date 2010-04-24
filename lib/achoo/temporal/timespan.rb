require 'achoo/temporal'
require 'time'

module Achoo
  module Temporal
    class Timespan < Range

      def initialize(start, end_)
        raise ArgumentError.new('Nil in parameters not allowed') if start.nil? || end_.nil?

        super(to_time(start), to_time(end_))
      end

      def to_s
        duration = duration_string
        from_to  = from_to_string

        sprintf("(%s) %s", duration, from_to)
      end

      def contains?(timeish_or_timespan)
        if timeish_or_timespan.is_a? Timespan
          time = timeish_or_timespan
          include?(time.first) && include?(time.last)
        else
          include?(to_time(timeish_or_timespan))
        end
      end

      def overlaps?(timespan)
        include?(timespan.first) || include?(timespan.last) ||
          timespan.contains?(self)
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
        "%d+%02d:%02d" % duration
      end

      def duration
        delta = last - first
        d     = delta.to_i / 1.day

        delta = delta - d.days
        h     = delta.to_i / 1.hour

        delta = delta - h.hours
        m     = delta.to_i / 1.minute

        return [d, h, m]
      end


      def from_to_string
        today      = Date.today
        start_date = first.send(:to_date)
        end_date   = last.send(:to_date)

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
        from = first.strftime(format << " %R")

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
        to = last.strftime(format)

        sprintf "%s - %s", from, to
      end

    end
  end
end

