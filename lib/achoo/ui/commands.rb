require 'achoo/hour_administration_form'
require 'achoo/lock_month_form'
require 'achoo/ui'
require 'achoo/term'

module Achoo::UI::Commands

  include Achoo::UI::DateChoosers
  include Achoo::UI::Common

  def show_registered_hours_for_day(agent)
    date = date_chooser
    form = Achoo::HourAdministrationForm.new(agent)
    form.show_registered_hours_for_day(date)
  end

  def show_registered_hours_for_week(agent)
    date = date_chooser
    form = Achoo::HourAdministrationForm.new(agent)
    form.show_registered_hours_for_week(date)
  end


  def show_flexi_time(agent)
    date = date_chooser
    form = Achoo::HourAdministrationForm.new(agent)
    balance = form.flexi_time(date)
    puts "Flexi time balance: #{Achoo::Term::underline(balance)}"
  end


  def lock_month(agent)
    month = month_chooser
    form   = Achoo::LockMonthForm.new(agent)
    form.lock_month(month)
    form.print_values
    if confirm
      form.submit
    else
      puts "Cancelled"
    end
  end

  
  def show_holiday_report(agent)
    page = agent.get(RC[:holiday_report_url])
    page.body.match(/<b>(\d+,\d+)<\/b>/)
    puts "Balance: #{Achoo::Term::underline($1)}"
  end


  def view_report(agent)
    choices = RC[:reports].keys
    answer = Achoo::Term.choose('Report', choices)
    key = choices[answer.to_i - 1]

    puts "Fetching data ..."
    page = agent.get(RC[:url] + RC[:reports][key])
    
    columns     = [0,1,2,5,6]
    source_rows = page.search('#rl_1 tr')
    headers     = extract_headers(source_rows, columns)
    data_rows   = extract_data_rows(source_rows, columns)
    summaries   = extract_summaries(source_rows, data_rows, columns)

    Achoo::Term::Table.new(headers, data_rows, summaries).print
  end

  def extract_headers(source_rows, columns)
    headers = source_rows.first.css('th')
    headers = headers.to_a.values_at(*columns)
    headers = headers.map {|th| th.content.strip}
    headers
  end

  def extract_data_rows(source_rows, columns)
    data_rows = []
    source_rows.each do |tr|
      cells = tr.css('td')
      next if cells.empty?
      cells = cells.to_a.values_at(*columns)
      data_rows << fix_empty_cells(cells.map {|td| td.content.strip})
    end
    data_rows
  end

  def extract_summaries(source_rows, data_rows, columns)
    summaries = nil
    unless data_rows.empty?
      summaries = source_rows.last.css('th')
      summaries = summaries.to_a.values_at(*columns)
      summaries = summaries.map {|th| th.content.strip }
      fix_empty_cells(summaries)
    end
    summaries
  end

  def fix_empty_cells(row)
    row.collect! {|c| c == "\302\240" ? '  ' : c} # UTF-8 NO-BREAK-SPACE
  end
end
