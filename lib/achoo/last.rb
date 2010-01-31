class Achoo
  class Last
    
    def initialize
      @output = %x{last reboot}
    end

    def find_by_date(date)
      @output.grep /#{date.strftime('%a\s%b\s+%d')}/
    end

  end
end
