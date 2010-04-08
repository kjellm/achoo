class Achoo
  module Achievo
    class Table < Array

      def initialize(source_rows)
        super()
        source_rows.each do |tr|
          cells = tr.css('td, th')
          cells = cells.collect {|c| c.content.strip}
          self << fix_empty_cells(cells)
        end
      end

      def select_columns(&block)
        columns = transpose
        columns = columns.select &block
        replace(columns.transpose)
      end

      private

      def fix_empty_cells(row)
        row.collect {|c| c == "\302\240" ? ' ' : c} # UTF-8 NO-BREAK-SPACE
      end

    end
  end
end
