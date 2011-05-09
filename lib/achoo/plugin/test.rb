require 'achoo/plugin'

class Test < Achoo::Plugin

  def before_register_hour_remark
    puts "before_register_hour_remark called"
  end

end

