require 'achoo/ui'

module Achoo::UI::DateChoosers

  def date_chooser
    Achoo::UI::DateChooser.new.choose
  end

  def optionally_ranged_date_chooser
    Achoo::UI::OptionallyRangedDateChooser.new.choose
  end

  def month_chooser
    Achoo::UI::MonthChooser.new.choose
  end

end
