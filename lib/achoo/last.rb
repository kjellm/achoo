require 'achoo/date_time_interval'

class Achoo::Last
    
  FILE_BOUNDARY_MARKER = "---"

  @@intervals         = nil
  @@suspend_intervals = nil

  def initialize
  end

  def find_by_date(date)
    intervals.find do |i| 
      if i.contains(date)
        puts i
        asleep = suspend_intervals.find_all {|j| i.contains_interval(j)}
        if asleep.length > 0
          print asleep.collect {|j| "  ZZZ  "+ j.to_s }.join("\n"), "\n"
        end
      end
    end
  end
  
  # ruby -Ilib -rachoo/last -le 'l = Achoo::Last.new; l.send(:process_suspend_logs); l.merge'
  def merge
    i = 0
    format = "%15s: %s\n"
    time_format = "%F %T"
    intervals.each do |last|
      printf format, "Powered off", last.end.strftime(time_format)
      while i < @@suspend_intervals.length && last.contains_interval(@@suspend_intervals[i])
        printf format, "Awake", @@suspend_intervals[i].end.strftime(time_format)
        printf format, "Suspend", @@suspend_intervals[i].start.strftime(time_format)
        i += 1
      end
      printf format, "Powered on", last.start.strftime(time_format)
      print "--------------"
    end
  end

  private

  def intervals
    process_last_logs unless @@intervals 
    @@intervals
  end

  def suspend_intervals
    process_suspend_logs unless @@suspend_intervals
    @@suspend_intervals
  end

  # wtmp file boundaries needs to be handled specially.
  def process_last_logs
    output = []
    wtmp = Dir.glob('/var/log/wtmp*').sort
    wtmp.each do |f|
      output.concat(%x{last -RF -f #{f} reboot}.split("\n"))
      output << FILE_BOUNDARY_MARKER
    end
    

    @@intervals = []
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
        @@intervals.last.start = interval.start
        merge_next = false
      else
        @@intervals << interval
      end
    end
  end

  def process_suspend_logs
    output = []
    pm_suspend = Dir.glob('/var/log/pm-suspend.log*').sort
    pm_suspend.each do |file|
      File.open(file, 'r') do |fh|
        output.concat(fh.readlines.collect {|l| l.chop}.grep(/Awake|performing suspend/).reverse)
      end
    end

    @@suspend_intervals = []
    interval = nil
    output.each do |l|
      l =~ /(.+): ([^:]+)$/
      date   = $1
      action = $2
      
      case action
      when 'performing suspend'
        interval.start = date
        @@suspend_intervals << interval
        interval = nil
      when 'Awake.'
        raise "Parse error: suspend/awake out of sync" unless interval.nil?
        interval = Achoo::DateTimeInterval.new
        interval.end = date
      else
        raise "Parse error"
      end
    end
  end

end
