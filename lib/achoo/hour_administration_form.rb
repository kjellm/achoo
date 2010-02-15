require 'achoo/form'
require 'achoo/term'

class Achoo::HourAdministrationForm < Achoo::Form

  def initialize(agent)
    @agent = agent
    @page  = nil
  end

  def show_registered_hours_for_day(date)
    show_registered_hours(date, 'dayview', '#rl_1 tr')
  end
  
  def show_registered_hours_for_week(date)
    show_registered_hours(date, 'weekview', '//form[@name="weekview"]/following::table/tr')
  end

  def flexi_time(date)
    set_page_to_view_for_date('dayview', date)

    @page.body.match(/Flexi time balance: (-?\d+:\d+)/)[1]
  end

  private
  
  def show_registered_hours(date, view, query)
    set_page_to_view_for_date(view, date)

    columns     = choose_source_columns(view, query)
    source_rows = @page.search(query)
    headers     = extract_headers(source_rows, columns, view)
    data_rows   = extract_data_rows(source_rows, columns)
    summaries   = extract_summaries(source_rows, data_rows, columns)

    Achoo::Term.table(headers, data_rows, summaries)
  end
  
  def set_page_to_view_for_date(view, date)
    @page ||= @agent.get(RC[:hour_admin_url])

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

  def choose_source_columns(view, query)
    columns = nil
    if view == 'dayview'
      # Ignore 'Billing billed', 'Billing marked', and 'Billing total'
      columns = [0,1,2,3,6,8,9]
      # Achievo prepends an extra column dynamically if there are
      # data rows.
      unless @page.search(query + ' td').empty?
        columns.collect! {|c| c + 1}
      end
    end
    columns
  end

  def extract_headers(source_rows, columns, view)
    headers = source_rows.first.css('th')
    unless columns.nil?
      headers = headers.to_a.values_at(*columns)
    end
    headers = headers.map {|th| th.content.strip}
    if view == 'weekview'
      headers = headers.map {|th| th.gsub(/\s+/, ' ') }
    end
    headers
  end

  def extract_data_rows(source_rows, columns)
    data_rows = []
    source_rows.each do |tr|
      cells = tr.css('td')
      next if cells.empty?
      unless columns.nil?
        cells = cells.to_a.values_at(*columns)
      end
      data_rows << fix_empty_cells(cells.map {|td| td.content.strip})
    end
    data_rows
  end

  def extract_summaries(source_rows, data_rows, columns)
    summaries = nil
    unless data_rows.empty?
      summaries = source_rows.last.css('th')
      unless columns.nil?
        summaries = summaries.to_a.values_at(*columns)
      end
      summaries = summaries.map {|th| th.content.strip }
      fix_empty_cells(summaries)
    end
    summaries
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
