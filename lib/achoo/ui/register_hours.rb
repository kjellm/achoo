require 'achoo/awake'
require 'achoo/hour_registration_form'
require 'achoo/ical'
require 'achoo/term'
require 'achoo/ui'
require 'achoo/vcs'
require 'stringio'

module Achoo::UI::RegisterHours

  include Achoo::UI::DateChoosers
  include Achoo::UI::ExceptionHandling

  def register_hours(agent)
    date       = optionally_ranged_date_chooser
    prefetcher = Thread.new { remark_helper_data(date) }

    puts "Fetching data ..."
    form = if true
             Achoo::HourRegistrationForm
           else
             Achoo::RangedHourRegistrationForm
           end.new(agent)

    form.date    = date
    form.project = project_chooser(form)
    form.phase   = phase_chooser(form)
    form.remark  = get_remark(date, prefetcher)
    form.hours   = hours_chooser(date)

    answer = Achoo::Term.ask("Do you want to change the defaults for worktime period and/or billing percentage? [N/y]").downcase
    if answer == 'y'
      form.workperiod = workperiod_chooser(form)
      form.billing    = billing_chooser(form)
    end

    form.print_values
    if confirm
      puts "Submitting ..."
      form.submit
    else
      puts "Cancelled"
    end
  end


  def phase_chooser(form)
    phases = form.phases_for_selected_project
    puts "Phases"
    answer = Achoo::Term.choose('Phase', phases.collect {|p| p[1] })
    phases[answer.to_i-1][0]
  end


  def workperiod_chooser(form)
    periods = form.worktime_periods
    puts "Worktime periods"
    answer = Achoo::Term.choose('Period [1]', periods.collect {|p| p[1] }, nil, [''])
    answer = '1' if answer.empty?
    periods[answer.to_i-1][0]
  end

  def billing_chooser(form)
    options = form.billing_options
    puts "Billing options"
    answer = Achoo::Term.choose('Billing [1]', options.collect {|p| p[1] }, nil, [''])
    answer = '1' if answer.empty?
    options[answer.to_i-1][0]
  end


  def hours_chooser(date)
    puts "Awake log:"
    begin
      awake = Achoo::Awake.new
      awake.find_by_date(date)
      puts
    rescue Exception => e
      print handle_exception("Failed to retrieve awake log.", e)
    end
    answer = Achoo::Term::ask 'Hours [7:30]'
    return answer == '' ? '7.5' : answer
  end


  def get_remark(date, prefetcher)
    puts "VCS logs for #{date}:"
    prefetcher.join
    print prefetcher[:vcs]
    puts '-' * 80 unless prefetcher[:vcs].empty?
    puts "Calendar events for #{date}:"
    puts '---' unless prefetcher[:ical].empty?
    print prefetcher[:ical]

    Achoo::Term::ask 'Remark'
  end


  def project_chooser(form)
    puts 'Recently used projects'
    projects = form.recent_projects
    answer = Achoo::Term.choose('Project [1]', projects.collect { |p| p[1] },
                       'Other', [''])
    case answer
    when ''
      projects[0][0]
    when '0'
      return all_projects_chooser(form)
    else
      return projects[answer.to_i-1][0]
    end
  end


  def all_projects_chooser(form)
    projects = form.all_projects
    answer = Achoo::Term.choose('Project', projects.collect { |p| p[1] })
    projects[answer.to_i-1][0]
  end


  def remark_helper_data(date)
    t = Thread.current

    begin
      io = StringIO.new
      Achoo::VCS.print_logs_for(date, RC[:vcs_dirs], io)
      t[:vcs] = io.string
    rescue Exception => e
      t[:vcs] = handle_exception("Failed to retrieve VCS logs.", e)
    end
    
    begin
      io = StringIO.new
      RC[:ical].each do |config|
        Achoo::ICal.from_http_request(config).print_events(date, io)
      end
      t[:ical] = io.string
    rescue Exception => e
      t[:ical] = handle_exception("Failed to retrieve calendar events.", e)
    end
  end
end
