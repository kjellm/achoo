require 'achoo/form'
require 'achoo/hour_administration_form'

class Achoo::HourRegistrationForm < Achoo::Form

  def initialize(agent)
    @agent = agent
    @page  = @agent.get(RC[:hour_registration_url])
    @form  = @page.form('entryform')

    if @form.nil?
      # Happens if the user has viewed a day or week report for a
      # locked month. Fetching todays day report should fix this in
      # most cases.

      # FIX Ugly call to a private method using send()
      haf    = Achoo::HourAdministrationForm.new(@agent)
      @page  = haf.send(:set_page_to_view_for_date, 'dayview', Date.today)
      @form  = @page.form('entryform')
    end

    if @form.nil?
      raise "Failed to retrieve the hour registration form.\nThe likely cause is that you have locked the current month, which is a silly thing to do."
    end

    @projects_seen = {}
    @phases_seen   = {}

    # Need to preselect this for some reason
    @form.field_with(:name => 'billpercent').options.first.select
    # Preselecting this one as well, just in case
    @form.field_with(:name => 'workperiod').options.first.select
  end

  def project
    extract_number_from_projectid(@form.projectid)
  end

  def project=(projectid)
    @form.projectid = "project.id='#{projectid}'"
  end

  def remark=(remark)
    @form.remark = remark
  end

  def hours=(hours)
    @form.time = hours
  end

  def phase
    @form.phaseid.match(/phase\.id='(\d+)'/)[1]
  end

  def phase=(phaseid)
    @form.phaseid   = "phase.id='#{phaseid}'"
  end

  def workperiod=(workperiod)
    @form.workperiod = "workperiod.id='#{workperiod}'"
  end

  def billing=(billing)
    @form.billpercent = "billpercent.id='#{billing}'"
  end


  def worktime_periods
    @form.field_with(:name => 'workperiod').options.collect do |opt|
      [opt.value.match(/workperiod\.id='(\d+)'/)[1], opt.text]
    end
  end

  def billing_options
    @form.field_with(:name => 'billpercent').options.collect do |opt|
      [opt.value.match(/billpercent\.id='(\d+)'/)[1], opt.text]
    end
  end

  def phases_for_selected_project
    partial_page = retrieve_project_phases_page
    page         = create_page_from_partial(partial_page)
    field        = page.forms.first.field_with(:name => 'phaseid')
    
    phases = []
    if field.respond_to?(:options)
      field.options.each do |opt|
        phases << [extract_number_from_phaseid(opt.value), opt.text]
      end
    else
      partial_page.body.match(/(^[^<]+)&nbsp;&nbsp;</)
      phases << [extract_number_from_phaseid(field.value), $1]
    end
    
    phases.each {|p| @phases_seen[p[0]] = p[1]}

    return phases
  end
  
  def recent_projects
    projects = []
    @form.field_with(:name => 'projectid').options.each do |opt|
      val = opt.value["project.id='".length..-2]
      projects << [val, opt.text]
    end

    projects.each {|p| @projects_seen[p[0]] = p[1]}

    projects
  end

  def all_projects
    puts "Getting project page #1..."
    projects_page = @agent.get(projects_url)
    projects = scrape_projects(projects_page)

    i = 2
    while (link = projects_page.link_with(:text => 'Next'))
      puts "Getting project page ##{i}..."
      projects_page = link.click
      projects.merge!(scrape_projects(projects_page))
      i += 1
    end

    projects.keys.sort.collect do |name|
      id   = projects[name][0]
      text = "#{projects[name][1]}: #{name}"
      @projects_seen[id] = text
      [id, text]
    end
  end

  def print_values
    format = "%10s: \"%s\"\n"
    printf format, 'date',     date_to_s
    printf format, 'project',  @projects_seen[project]
    printf format, 'phase',    @phases_seen[phase]
    printf format, 'remark',   @form.remark
    printf format, 'hours',    @form.time
    printf format, 'worktime', @form.field_with(:name => 'workperiod').selected_options.first.text
    printf format, 'billing',  @form.field_with(:name => 'billpercent').selected_options.first.text


    # @form.fields.each do |field|
    #   printf format, field.name, field.value
    # end

  end

  def submit
    @form.submit()
  end

  private

  def date_to_s
    date.strftime("%Y-%m-%d")
  end

  def retrieve_project_phases_page
    old = {
      :atkaction => @form.atkaction,
      :action    => @form.action,
    }
    
    @form.action = RC[:url]+"/dispatch.php?atkpartial=attribute.phaseid.refresh"
    @form.atkaction = 'add'
    partial_page = @form.submit
    @form.action    = old[:action]
    @form.atkaction = old[:atkaction]
    
    return partial_page
  end

  def create_page_from_partial(partial_page)
    body = "<html><head></head><body><form>#{partial_page.body}</form></body></html>"
    page = Mechanize::Page.new(nil, {'content-type' => 'text/html; charset=iso-8859-1'},
                               body, nil, @agent)
  end

  def day_field
    @form.field_with(:name => 'activitydate[day]')
  end

  def month_field
    @form.field_with(:name => 'activitydate[month]')
  end

  def year_field
    @form.field_with(:name => 'activitydate[year]')
  end

  def extract_number_from_projectid(projectid)
    projectid.match(/project\.id='(\d+)'/)[1]
  end

  def extract_number_from_phaseid(projectid)
    projectid.match(/phase\.id='(\d+)'/)[1]
  end

  def projects_url
    atk_submit_to_url(@page.link_with(:text => 'Select project').href)
  end

  def atk_submit_to_url(atk_submit)
    href = atk_submit['javascript:atkSubmit("__'.length..-3]
    href.gsub!('_13F', '?')
    href.gsub!('_13D', '=')
    href.gsub!('_126', '&')
    href.gsub!('_125', '%')
    return RC[:url] + '/' + href
  end

  def scrape_projects(projects_page)
    projects = {}
    projects_page.search('table#rl_1 tr').each do |tr|
      cells = tr.search('td')
      next if cells.empty?
      projects[cells[1].text.strip] = [
        cells[1].at_css('a').attribute('href').to_s.match('project.id%3D%27(\d+)%27')[1],
        cells[0].text.strip,
      ]
    end

    return projects
  end

end
