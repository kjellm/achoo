require 'achoo'

module Achoo::System
  autoload :CStruct,    'achoo/system/cstruct'
  autoload :PMSuspend,  'achoo/system/pm_suspend.rb'
  autoload :UTMPRecord, 'achoo/system/utmp_record'
  autoload :Wtmp,       'achoo/system/wtmp.rb'
end
