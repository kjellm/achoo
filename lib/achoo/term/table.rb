if RUBY_VERSION < "1.9"
  $KCODE = 'u'
  require 'jcode'
end

class Achoo
  class Term
    class Table

      def initialize(headers, data_rows, summaries=nil)
        @headers   = headers
        @data_rows = data_rows
        @summaries = summaries
      end

      def print(io=$stdout)
        lengths   = calculate_table_cell_widths
        separator = table_separator(lengths)
        format    = build_format(lengths)
        
        headers   = center_table_headers(lengths)
        
        io.puts separator
        io.print '| ' << headers.join(' | ') << " |\n"
        io.puts separator
        @data_rows.each {|r| io.printf format, *r }
        io.puts separator
        unless @summaries.nil? || @data_rows.length == 1
          io.printf format, *@summaries
          io.puts separator
        end
      end

      private

      def center_table_headers(lengths)
        headers = @headers.dup
        lengths.each_with_index do |len,i|
          headers[i] = headers[i].center(len)
        end
        headers
      end

      def calculate_table_cell_widths
        lengths = []
        @headers.each_with_index do |h, i|
          lengths[i] = RUBY_VERSION < '1.9' ? h.jlength : h.length
        end
        @data_rows.each do |r|
          r.each_with_index do |d, i|
            len = RUBY_VERSION < '1.9' ? d.jlength : d.length
            lengths[i] = [len, lengths[i]].max
          end
        end
        lengths
      end

      def build_format(lengths)
        is_column_left_justified = Array.new(lengths.nitems)
        is_column_left_justified.fill(false)
        
        @data_rows.each do |r|
          r.each_index do |c|
            if !r[c].strip.empty? && !r[c].match(/^\d+[:.,]?\d*$/)
              is_column_left_justified[c] = true
            end
          end
        end
        
        lengths.reduce('|') do |f, l|
          justify = is_column_left_justified.shift ? '-' : ''
          f + " %#{justify}#{l}s |"
        end + "\n"
      end

      def table_separator(lengths)
        lengths.reduce('+') {|s, length| s + '-'*(length+2) + '+'}
      end

    end
  end
end
