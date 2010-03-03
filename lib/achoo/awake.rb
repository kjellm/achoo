require 'achoo/date_time_interval'

class Achoo; end

class Achoo::Awake
    
  @@intervals         = nil
  @@suspend_intervals = nil

  def initialize
  end

  def find_by_date(date)
    intervals.each do |i| 
      if i.contains(date)
        print_session(i, date)
      end
    end
  end
  
  def all
    intervals.each { |i| print_session(i) }
  end

  private

  def print_session(powered_on_interval, date=nil)
    puts "Powered on: " << powered_on_interval.to_s
    asleep = suspend_intervals.reverse.find_all do |j|
      powered_on_interval.contains_interval(j)
    end
    unless asleep.empty?
      start = powered_on_interval.start
      asleep.each do |j|
        dti = Achoo::DateTimeInterval.new(start, j.start)
        puts "  Awake: " + dti.to_s if date.nil? || dti.contains(date)
        start = j.end
      end
      dti = Achoo::DateTimeInterval.new(start, powered_on_interval.end)
      puts "  Awake: " + dti.to_s if date.nil? || dti.contains(date)       
    end
  end

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
    file_boundary_marker = "---"
    
    output = []
    wtmp = Dir.glob('/var/log/wtmp*').sort
    wtmp.each do |f|
      o = %x{last -RF -f #{f} reboot}.split("\n").grep(/^reboot/)
      next if o.empty?
      output.concat(o)
      output << file_boundary_marker
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
        if line == file_boundary_marker
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
