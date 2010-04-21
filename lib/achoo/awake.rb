require 'achoo'
require 'achoo/extensions'
require 'achoo/system'
require 'achoo/temporal'

module Achoo
  class Awake

    def initialize
      log = wtmp.merge!(suspend).reverse
      log.unshift(System::LogEntry.new(Time.now, :now))
      @sessions = sessions(log)
    end

    def at(date)
      span = Temporal::Timespan.new(date, date+1)
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

    def sessions(log)
      sessions = []
      group(log).each do |g|
        raise "Session doesn't begin with a boot event" unless g.last.event == :boot
        
        session = []
        case g.first.event
        when :now, :halt, :suspend
          # We know the end of the session
          session << Temporal::Timespan.new(g.last.time, g.first.time)
        else # :awake, :boot
          # We don't know the end of the session
          session << Temporal::OpenTimespan.new(g.last.time, g.first.time)
          g.unshift(System::LogEntry.new(-1, :crash))
        end
      
        raise "Session must consist of even number of events. Found #{g.length}" unless g.length.even?
        

        session << []
        unless g.length == 2
          i = 0
          while i < g.length-1
            klass = g[i].event == :crash ? Temporal::OpenTimespan : Temporal::Timespan
            session[1] << klass.new(g[i+1].time, g[i].time)
            i += 2
          end
        end
      
        sessions << session
      end
      sessions
    end

    def suspend
      System::PMSuspend.new
    end

    def wtmp
      log     = System::Wtmp.new
      new_log = []
      log.each do |entry|
        if entry.boot_event?
          new_log << System::LogEntry.new(entry.time, :boot)
        elsif entry.halt_event?
          new_log << System::LogEntry.new(entry.time, :halt)
        end
      end
      new_log
    end

    def group(log)
      grouped_log = []
      group = nil
      log.each do |i|
        if i.event == :halt || i.event == :now
          group = [i]
        else
          if group.nil?
            # Crashed
            group = []
          end
          group << i
          if i.event == :boot
            grouped_log << group
            group = nil
          end    
        end
      end
      grouped_log
    end


  end
end
