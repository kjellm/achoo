require 'achoo/timespan'
require 'achoo/system'

class Achoo; end

class Achoo::Awake
    
  def initialize
    @intervals         = nil
    @suspend_intervals = nil
  end

  def find_by_date(date)
    intervals.each do |i| 
      if i.contains?(date)
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
      powered_on_interval.contains?(j)
    end
    unless asleep.empty?
      start = powered_on_interval.start
      asleep.each do |j|
        dti = Achoo::Timespan.new(start, j.start)
        puts "  Awake: " + dti.to_s if date.nil? || dti.contains?(date)
        start = j.end
      end
      dti = Achoo::Timespan.new(start, powered_on_interval.end)
      puts "  Awake: " + dti.to_s if date.nil? || dti.contains?(date)       
    end
  end

  def intervals
    process_last_logs unless @intervals 
    @intervals
  end

  def suspend_intervals
    process_suspend_log unless @suspend_intervals
    @suspend_intervals
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
    
    @intervals = []
    merge_next = false
    output.each do |line|
      interval = nil
      if line.match(/^reboot\s+system\sboot\s+(.*?)\s+\(/)
        $1 =~ /(.*) - (.*)/
        interval = Achoo::Timespan.new($1, $2)
      else
        if line == file_boundary_marker
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

  def process_suspend_log
    log = Achoo::System::PMSuspend.new

    @suspend_intervals = []
    to = nil
    log.each do |l|
      case l.action
      when 'performing suspend'
        @suspend_intervals << Achoo::Timespan.new(l.time, to)
        to = nil
      when 'Awake.'
        raise "Parse error: suspend/awake out of sync" unless to.nil?
        to = l.time
      else
        raise "Parse error"
      end
    end
  end

end
