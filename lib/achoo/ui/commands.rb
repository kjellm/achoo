require 'achoo/hour_administration_form'
require 'achoo/lock_month_form'
require 'achoo/ui'

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


end
