class Achoo::Term

  def self.bold(text)
    "\e[1m#{text}\e[0m"
  end

  def self.menu(entries, special=nil)
    max_digits = Math.log10(entries.length).to_i
    format = "% #{max_digits}d. %s\n"
    entries.each_with_index do |entry, i|
      printf format, i+1, entry
    end
    printf format, 0, special unless special.nil?
  end

  def self.table(headers, data_rows, summaries=nil)
    lengths = calculate_table_cell_widths(headers, data_rows)
    separator = table_separator(lengths)
    format = build_format(lengths)
    
    puts separator
    printf format, *headers
    puts separator
    data_rows.each {|r| printf format, *r }
    puts separator
    unless summaries.nil? || data_rows.length == 1
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

  def self.build_format(lengths)
    lengths.reduce('|') {|f, l| f + " %-#{l}s |"} + "\n"
  end

  def self.table_separator(lengths)
    lengths.reduce('+') {|s, length| s + '-'*(length+2) + '+'}
  end

end
