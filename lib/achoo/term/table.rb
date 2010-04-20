# encoding: utf-8

require 'achoo/term'


# Unicode box drawing characters
#
# http://en.wikipedia.org/wiki/Box-drawing_characters
#
#
#      0 1 2 3 4 5 6 7 8 9 A B C D E F
#
# 2500 ─ ━ │ ┃ ┄ ┅ ┆ ┇ ┈ ┉ ┊ ┋ ┌ ┍ ┎ ┏
#
# 2510 ┐ ┑ ┒ ┓ └ ┕ ┖ ┗ ┘ ┙ ┚ ┛ ├ ┝ ┞ ┟
#
# 2520 ┠ ┡ ┢ ┣ ┤ ┥ ┦ ┧ ┨ ┩ ┪ ┫ ┬ ┭ ┮ ┯
#
# 2530 ┰ ┱ ┲ ┳ ┴ ┵ ┶ ┷ ┸ ┹ ┺ ┻ ┼ ┽ ┾ ┿
#
# 2540 ╀ ╁ ╂ ╃ ╄ ╅ ╆ ╇ ╈ ╉ ╊ ╋ ╌ ╍ ╎ ╏
#
# 2550 ═ ║ ╒ ╓ ╔ ╕ ╖ ╗ ╘ ╙ ╚ ╛ ╜ ╝ ╞ ╟
#
# 2560 ╠ ╡ ╢ ╣ ╤ ╥ ╦ ╧ ╨ ╩ ╪ ╫ ╬ ╭ ╮ ╯
#
# 2570 ╰ ╱ ╲ ╳ ╴ ╵ ╶ ╷ ╸ ╹ ╺ ╻ ╼ ╽ ╾ ╿

module Achoo
  class Term
    class Table

      def initialize(headers, data_rows, summaries=nil)
        @headers   = headers
        @data_rows = data_rows
        @summaries = summaries
      end

      def print(io=$stdout)
        lengths   = calculate_table_cell_widths
        format    = build_format(lengths)
        headers   = center_table_headers(lengths)
        separator = lengths.map {|length| '─'*(length+2)}
    

        io.print '┌' << separator.join('┬') << "┐\n"
        io.print '│ ' << headers.join(' │ ') << " │\n"
        io.print '├' << separator.join('┼') << "┤\n"
        @data_rows.each {|r| io.printf format, *r }
        unless @summaries.nil? || @data_rows.length == 1
          io.print '├' << separator.join('┼') << "┤\n"
          io.printf format, *@summaries
        end
        io.print '└' << separator.join('┴') << "┘\n"
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
          lengths[i] = h.length
        end
        @data_rows.each do |r|
          r.each_with_index do |d, i|
            lengths[i] = [d.length, lengths[i]].max
          end
        end
        lengths
      end

      def build_format(lengths)
        is_column_left_justified = Array.new(lengths.count)
        is_column_left_justified.fill(false)
    
        @data_rows.each do |r|
          r.each_index do |c|
            if !r[c].strip.empty? && !r[c].match(/^\d+[:.,]?\d*$/)
              is_column_left_justified[c] = true
            end
          end
        end
    
        lengths.reduce('│') do |f, l|
          justify = is_column_left_justified.shift ? '-' : ''
          f + " %#{justify}#{l}s │"
        end + "\n"
      end

    end
  end
end
