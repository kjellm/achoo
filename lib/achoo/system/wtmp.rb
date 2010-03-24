require 'achoo/binary'

class Achoo; module System; end; end

class Achoo::System::WTMP

  def initialize(glob='/var/log/wtmp*')
    @records = []
    chunk_size = Achoo::Binary::UTMPRecord.bin_size
    Dir.glob(glob).sort.reverse.each do |file|
      File.open(file, 'r') do |io|
        while (bytes = io.read(chunk_size)) 
          @records << Achoo::Binary::UTMPRecord.new(bytes)
        end
      end
    end
  end
  
  def select(&block)
    @records.select &block
  end

  def print_log
    @records.each do |r|
      puts r.to_s
    end
  end

end

