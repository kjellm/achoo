require 'achoo/term'

class Achoo
  class HourAdministrationForm

    def initialize(agent)
      @agent = agent
      @page  = @agent.get(RC[:url] + '/dispatch.php?atknodetype=timereg.hours&atkaction=admin&atklevel=-1&atkprevlevel=0&')
      @form  = @page.form('dayview')
    end

    def show_registered_hours_for_day(date)
      @page = get_page_for(date) unless date == self.date

      columns = [1,2,3,4,7,8,9,10] # ignore 'Biling billed' and 'Billing marked'
      if @page.search('#rl_1 tr td').empty?
        columns.collect! {|c| c - 1}
      end

      headers = @page.search('#rl_1 tr').first.css('th').to_a.values_at(*columns)
      headers = headers.map {|th| th.content.strip}

      data_rows = []
      @page.search('#rl_1 tr').each do |tr|
        cells = tr.css('td')
        next if cells.empty?
        cells = cells.to_a.values_at(*columns)
        data_rows << cells.map {|td| td.content.strip}
      end

      # FIX add summary for hours and billing total

      Achoo::Term.table(headers, data_rows)
    end
    
    def flexi_time(date)
      @page = get_page_for(date) unless date == self.date

      @page.body.match(/(Flexi time balance: -?\d+:\d+)/)[1]
    end

    def date=(date)
      # Day and month must be prefixed with '0' if single
      # digit. Date.day and Date.month doesn't do this. Use strftime
      day_field.value   = date.strftime('%d')
      month_field.value = date.strftime('%m')
      year_field.value  = date.year
    end

    def date
      Date.new(year_field.value.to_i, 
               month_field.value.to_i, 
               day_field.value.to_i)
    end

    private

    def get_page_for(date)
      puts "Fetching data for #{date} ..."
      self.date = date
      @page = @form.submit
    end

    def day_field
      @form.field_with(:name => 'viewdate[day]')
    end
    
    def month_field
      @form.field_with(:name => 'viewdate[month]')
    end
    
    def year_field
      @form.field_with(:name => 'viewdate[year]')
    end
  end  
end
