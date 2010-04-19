require 'achoo'

module Achoo::System
  autoload :CStruct,    'achoo/system/cstruct'
  autoload :LogEntry,   'achoo/system/log_entry'
  autoload :PMSuspend,  'achoo/system/pm_suspend'
  autoload :UTMPRecord, 'achoo/system/utmp_record'
  autoload :Wtmp,       'achoo/system/wtmp'
end
