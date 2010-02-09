require 'achoo/form'
require 'achoo/term'

class Achoo
  class HourAdministrationForm < Achoo::Form

    def initialize(agent)
      @agent = agent
      @page  = @agent.get(RC[:hour_admin_url])
    end

    def show_registered_hours_for_day(date)
      show_registered_hours(date, 'dayview', '#rl_1 tr')
    end
    
    def show_registered_hours_for_week(date)
      show_registered_hours(date, 'weekview', '//form[@name="weekview"]/following::table/tr')
    end

    def flexi_time(date)
      set_page_to_view_for_date('dayview', date)

      @page.body.match(/(Flexi time balance: -?\d+:\d+)/)[1]
    end

    private
    
    def show_registered_hours(date, view, query)
      set_page_to_view_for_date(view, date)

      columns = nil
      if view == 'dayview'
        columns = [1,2,3,4,7,8,9,10] # ignore 'Biling billed' and 'Billing marked'
        if @page.search(query + ' td').empty?
          columns.collect! {|c| c - 1}
        end
      end

      rows = @page.search(query)

      headers = rows.first.css('th')
      if view == 'dayview'
        headers = headers.to_a.values_at(*columns)
      end
      headers = headers.map {|th| th.content.strip}
      if view == 'weekview'
        headers = headers.map {|th| th.gsub(/\s+/, ' ') }
      end


      data_rows = []
      rows.each do |tr|
        cells = tr.css('td')
        next if cells.empty?
        if view == 'dayview'
          cells = cells.to_a.values_at(*columns)
        end
        data_rows << fix_empty_cells(cells.map {|td| td.content.strip})
      end

      summaries = nil
      unless data_rows.empty?
        summaries = rows.last.css('th')
        if view == 'dayview'
          summaries = summaries.to_a.values_at(*columns)
        end
        summaries = summaries.map {|th| th.content.strip }
        fix_empty_cells(summaries)
      end

      Achoo::Term.table(headers, data_rows, summaries)
    end

    
    def set_page_to_view_for_date(view, date)
      link = @page.link_with(:text => view.capitalize)
      @form = @page.form(view)
      unless link.nil?
        puts "Fetching #{view} ..."
        @page = link.click
        @form = @page.form(view)
      end
      unless date == self.date
        @page = get_page_for(date)
        @form = @page.form(view)
      end
    end    

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
