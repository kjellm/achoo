class Achoo
  class Term

    def self.table(headers, data_rows, summaries=nil)
      lengths = calculate_table_cell_widths(headers, data_rows)
      separator = table_separator(lengths)
      format = lengths.reduce('|') {|f, l| f + " %-#{l}s |"} + "\n"
      
      puts separator
      printf format, *headers
      puts separator
      data_rows.each do |r|
        printf format, *r
      end
      puts separator
      unless summaries.nil?
        printf format, *summaries
        puts separator
      end
    end

    private

    def self.calculate_table_cell_widths(headers, data_rows)
      lengths = []
      headers.each_with_index do |h, i|
        lengths[i] = h.length
      end
      data_rows.each do |r|
        r.each_with_index do |d, i|
          lengths[i] = [d.length, lengths[i]].max
        end
      end
      lengths
    end

    def self.table_separator(lengths)
      lengths.reduce('+') {|s, length| s + '-'*(length+2) + '+'}
    end

  end
end
