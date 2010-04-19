require 'achoo'

module Achoo
  module UI
    autoload :Commands,                    'achoo/ui/commands'
    autoload :Common,                      'achoo/ui/common'
    autoload :DateChooser,                 'achoo/ui/date_chooser'
    autoload :DateChoosers,                'achoo/ui/date_choosers'
    autoload :ExceptionHandling,           'achoo/ui/exception_handling'
    autoload :MonthChooser,                'achoo/ui/month_chooser'
    autoload :OptionallyRangedDateChooser, 'achoo/ui/optionally_ranged_date_chooser'
    autoload :RegisterHours,               'achoo/ui/register_hours'
  end
end
