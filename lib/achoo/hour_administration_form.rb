require 'achoo/form'
require 'achoo/term'

class Achoo
  class HourAdministrationForm < Achoo::Form

    def initialize(agent)
      @agent = agent
      @page  = @agent.get(RC[:hour_admin_url])
    end

    def show_registered_hours_for_day(date)
      link = @page.link_with(:text => 'Dayview')
      unless link.nil?
        @page = link.click
      end
      @form = @page.form('dayview')
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
        data_rows << fix_empty_cells(cells.map {|td| td.content.strip})
      end

      summaries = nil
      unless data_rows.empty?
        summaries = @page.search('#rl_1 tr').last.css('th').to_a.values_at(*columns)
        summaries = summaries.map {|th| th.content.strip }
        fix_empty_cells(summaries)
      end

      Achoo::Term.table(headers, data_rows, summaries)
    end
    
    def show_registered_hours_for_week(date)
      link = @page.link_with(:text => 'Weekview')
      unless link.nil?
        @page = link.click
      end
      @form = @page.form('weekview')
      unless date == self.date
        puts "Fetching data for #{date} ..."
        self.date = date
        @page = @form.submit
      end
      
      headers = @page.search('//form[@name="weekview"]/following::table/tr').first.css('th')
      headers = headers.map {|th| th.content.match(/^(\S+)/)[1] }
      # FIX add a second header row with dates

      data_rows = []
      @page.search('//form[@name="weekview"]/following::table/tr').each do |tr|
        cells = tr.css('td')
        next if cells.empty?
        data_rows << fix_empty_cells(cells.map {|td| td.content.strip})
      end

      summaries = @page.search('//form[@name="weekview"]/following::table/tr').last.css('th')
      summaries = summaries.map {|th| th.content }
      fix_empty_cells(summaries)
      
      Achoo::Term.table(headers, data_rows, summaries)
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

    def fix_empty_cells(row)
      row.collect! {|c| c == "\302\240" ? '  ' : c} # UTF-8 NO-BREAK-SPACE

    end
  end  
end
