class Achoo::Form

  def date=(date)
    # Day and month must be prefixed with '0' if single
    # digit. Date.day and Date.month doesn't do this. Use strftime
    day_field.value   = date.strftime('%d')
    month_field.value = date.strftime('%m')
    year_field.value  = date.year
  end

  def date
    Date.new(year_field.value.to_i, month_field.value.to_i, 
             day_field.value.to_i)
  end
end
