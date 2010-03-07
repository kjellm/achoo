require 'achoo/ui/date_chooser'
require 'achoo/ui/optionally_ranged_date_chooser'
require 'achoo/ui/month_chooser'

class Achoo; class UI; end; end

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
