require 'achoo/hour_registration_form'

class Achoo::HourRegistrationFormRanged < Achoo::HourRegistrationForm

  def initialize(agent)
    super
    
    @page = @agent.get(atk_submit_to_url(@page.link_with(:text => 'Select range').href))
    @form = @page.form('entryform')
  end

  def date=(date_range)
    super(date_range[0])

    to_day_field.value   = date_range[1].strftime('%d')
    to_month_field.value = date_range[1].strftime('%m')
    to_year_field.value  = date_range[1].year
  end

  def date
    start = super
    finish = Date.new(to_year_field.value.to_i, to_month_field.value.to_i, 
                      to_day_field.value.to_i)
    [start, finish]
  end
  
  private

  def to_day_field
    @form.field_with(:name => 'todate[day]')
  end

  def to_month_field
    @form.field_with(:name => 'todate[month]')
  end

  def to_year_field
    @form.field_with(:name => 'todate[year]')
  end

  def date_to_s
    date.map {|d| d.strftime("%Y-%m-%d")}.join(" -> ")
  end
    
end
