require 'achoo/system'

module Achoo
  module System

    class Wtmp < Array

      def initialize(glob='/var/log/wtmp*')
        super()
        chunk_size = UTMPRecord.bin_size
        Dir.glob(glob).sort.reverse.each do |file|
          File.open(file, 'r') do |io|
            while (bytes = io.read(chunk_size)) 
              self << UTMPRecord.new(bytes)
            end
          end
        end
      end

    end
  end
end
