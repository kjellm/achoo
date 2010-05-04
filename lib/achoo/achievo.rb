require 'achoo'
require 'achoo/achievo/date_field'

module Achoo
  module Achievo
    autoload :HourAdministrationForm,     'achoo/achievo/hour_administration_form.rb'
    autoload :HourRegistrationForm,       'achoo/achievo/hour_registration_form.rb'
    autoload :HourRegistrationFormRanged, 'achoo/achievo/hour_registration_form_ranged.rb'
    autoload :LockMonthForm,              'achoo/achievo/lock_month_form.rb'
    autoload :LoginForm,                  'achoo/achievo/login_form.rb'
    autoload :Table,                      'achoo/achievo/table.rb'
  end
end
