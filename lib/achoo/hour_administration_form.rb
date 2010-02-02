require 'achoo/form'
require 'achoo/term'

class Achoo
  class HourAdministrationForm < Achoo::Form

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
