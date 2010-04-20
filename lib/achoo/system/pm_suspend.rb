require 'achoo/system'
require 'time'

module Achoo
  module System

    class PMSuspend < Array

      def initialize(glob='/var/log/pm-suspend.log*')
        super()
        Dir.glob(glob).sort.reverse.each do |file|
          next if file =~ /\.gz$/ # FIX uncompress?
          File.open(file, 'r') do |fh|
            fh.readlines.each do |l|
              l.chop!
              next unless l =~ /Awake|performing suspend/
              time, event = *l.split(': ')
              time = Time.parse(time)
              self << LogEntry.new(time, event == 'Awake.' ? :awake : :suspend)
            end
          end
        end
      end

    end
  end
end
