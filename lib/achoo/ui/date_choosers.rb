require 'achoo/ui'

module Achoo
  module UI

    module DateChoosers

      def date_chooser
        DateChooser.new.choose
      end

      def optionally_ranged_date_chooser
        OptionallyRangedDateChooser.new.choose
      end

      def month_chooser
        MonthChooser.new.choose
      end

    end
  end
end
