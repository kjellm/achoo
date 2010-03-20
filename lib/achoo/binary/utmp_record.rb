require 'achoo/binary'

class Achoo::Binary::UTMPRecord < Achoo::Binary::CStruct
  long   :record_type
  long   :process_id
  string :device_name,        32
  string :inittab_id,          4
  string :username,           32
  string :hostname,          256
  short  :termination_status
  short  :exit_status
  long   :session_id
  long   :seconds
  long   :milliseconds
  long   :ip_address1
  long   :ip_address2
  long   :ip_address3
  long   :ip_address4
  string :unused,             20


  TYPE_MAP = [:empty,
              :run_lvl,
              :boot,
              :new_time,
              :old_time,
              :init,
              :login,
              :normal,
              :term,
              :account,
             ]
  
  def time
    return nil if seconds.nil?
    @time ||= Time.at(seconds, milliseconds)
  end
  
  def to_s
    sprintf "%s  %-7s  %-8s %s", time.strftime('%F_%T'), TYPE_MAP[record_type], username, device_name
  end
  
end
