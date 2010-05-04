require 'achoo/achievo'

module Achoo
  module Achievo

    def self.DateField(attr_name, field_name)
      Module.new do
        define_method("#{attr_name}=") do |date|
          # Day and month must be prefixed with '0' if single
          # digit. Date.day and Date.month doesn't do this. Use strftime
          send("#{attr_name}_day_field=",   date.strftime('%d'))
          send("#{attr_name}_month_field=", date.strftime('%m'))
          send("#{attr_name}_year_field=",  date.year)
        end
        
        define_method("#{attr_name}") do
          Date.new(*[send("#{attr_name}_year_field"),
                     send("#{attr_name}_month_field"),
                     send("#{attr_name}_day_field")].collect {|e| e.to_i})
        end
        
        %w(day month year).each do |e|
          define_method("#{attr_name}_#{e}_field") do
            @form.field_with(:name => "#{field_name}[#{e}]").value
          end 
              
          define_method("#{attr_name}_#{e}_field=") do |val|
            @form.field_with(:name => "#{field_name}[#{e}]").value = val
          end 
        end
      end
    end

  end
end
