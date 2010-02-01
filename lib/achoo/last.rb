class Achoo
  class Last
    
    def initialize
      @output = []
      Dir.glob('/var/log/wtmp*').each do |f|
        @output.concat(%x{last -R -f #{f} reboot}.split("\n"))
      end
    end

    def find_by_date(date)
      date_pattern = date.strftime('%a\s%b\s+%d')
      @output.grep /#{date_pattern}/
    end

  end
end
