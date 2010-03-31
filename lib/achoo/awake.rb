require 'achoo/open_timespan'
require 'achoo/timespan'
require 'achoo/system'

class Achoo; end

class Achoo::Awake
    
  def initialize
    suspend = filter_and_translate_suspend(Achoo::System::PMSuspend.new.reverse)
    wtmp    = filter_and_translate_wtmp(Achoo::System::Wtmp.new.reverse)
    log = merge(wtmp, suspend)
    log.unshift([Time.now, :now])
    @sessions = to_intervals(log)
  end

  def at(date)
    span = Achoo::Timespan.new(date, date+1)
    @sessions.each do |s|
      print_session(s, span) if s[0].overlaps?(span)
    end
  end
  
  def all
    @sessions.each do |s|
      print_session(s)
    end
  end

  private

  def print_session(s, span=nil)
    puts "Powered on: " << s[0].to_s
    s[1].each do |t|
      puts "  Awake: " << t.to_s if span.nil? || t.overlaps?(span)
    end
  end

  def to_intervals(log)
    @sessions = group(log)
    foo = []
    @sessions.each do |g|
      raise "Foo" unless g.last[1] == :boot
      
      bar = []
      
      if g.first[1] == :now || g.first[1] == :halt || g.first[1] == :suspend
        # We know the end of the session
        raise "Foo" if g.length < 2
        bar << Achoo::Timespan.new(g.last[0], g.first[0])
      elsif g.first[1] == :awake || g.first[1] == :boot
        # We don't know the end of the session
        bar << Achoo::OpenTimespan.new(g.last[0], g.first[0])
        g.unshift([-1, :crash])
      else
        raise "Foo"
      end
      
      raise "Foo" unless g.length.even?

      bar << []
      
      unless g.length == 2 && [:crash, :halt, :now].find(g.first[1]) && g.last[1] == :boot
        i = 0
        while i < g.length-1
          bar[1] << Achoo::Timespan.new(g[i+1][0], g[i][0])
          i += 2
        end
      end
      
      foo << bar
    end
    foo
  end

  def merge(wtmp, suspend)
    log = []
    until wtmp.empty? or suspend.empty?
      if wtmp.first[0] >= suspend.first[0]
        log << wtmp.shift
      else
        log << suspend.shift
      end
    end
    log.concat(wtmp).concat(suspend)
    log
  end

  def filter_and_translate_suspend(log)
    new_log = []
    log.each do |entry|
      new_log << [entry.time, entry.action == 'Awake.' ? :awake : :suspend]
    end
    new_log
  end

  def filter_and_translate_wtmp(log)
    new_log = []
    log.each do |entry|
      if entry.record_type_symbol == :boot
        new_log << [entry.time, :boot]
      elsif entry.record_type_symbol == :term && entry.device_name == ':0'
        new_log << [entry.time, :halt]
      end
    end
    new_log
    
  end

  def group(log)
    grouped_log = []
    group = nil
    log.each do |i|
      if i[1] == :halt || i[1] == :now
        group = [i]
      else
        if group.nil?
          # Crashed
          group = []
        end
        if i[1] == :boot
          group << i
          grouped_log << group
          group = nil
        else
          group << i
        end    
      end
    end
    grouped_log
  end


end
