require 'achoo/binary'
require 'achoo/system'

class Achoo::System::Wtmp < Array

  def initialize(glob='/var/log/wtmp*')
    super()
    chunk_size = Achoo::Binary::UTMPRecord.bin_size
    Dir.glob(glob).sort.reverse.each do |file|
      File.open(file, 'r') do |io|
        while (bytes = io.read(chunk_size)) 
          self << Achoo::Binary::UTMPRecord.new(bytes)
        end
      end
    end
  end
  
  def print_log
    @records.each do |r|
      puts r.to_s
    end
  end

end
