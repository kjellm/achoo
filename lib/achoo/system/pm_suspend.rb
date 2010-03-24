require 'achoo/system'

class Achoo::System::PMSuspend < Array

  class LogEntry
    attr :time
    attr :action
    
    def initialize(time_str, action)
      @action = action
      @time   = time_str
    end
  end

  def initialize(glob='/var/log/pm-suspend.log*')
    super()
    Dir.glob(glob).sort.each do |file|
      File.open(file, 'r') do |fh|
        fh.readlines.each do |l|
          l.chop!
          next unless l =~ /Awake|performing suspend/
          self << LogEntry.new(*l.split(': '))
        end
      end
    end
  end

end
