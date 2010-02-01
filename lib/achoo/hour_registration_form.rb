class Achoo
  class HourRegistrationForm

    def initialize(agent)
      @agent = agent
      @page  = @agent.get(RC[:url] + '/dispatch.php?atknodetype=timereg.hours&atkaction=admin&atklevel=-1&atkprevlevel=0&')
      @form  = @page.form('entryform')
    end

    def list_recent_projects
      @form.field_with(:name => 'projectid').options.each do |opt|
        val = opt.value["project.id='".length..-2]
        printf "%6s - %s\n", val, opt.text
      end
    end

    def list_all_projects
      projects_page = @agent.get(projects_url)
      projects = scrape_projects(projects_page)

      while (link = projects_page.link_with(:text => 'Next'))
        projects_page = link.click
        projects.merge!(scrape_projects(projects_page))
      end

      projects.keys.sort.each do |name|
        puts "X - #{projects[name]}: #{name}"
      end
    end

    def set_values(values)
      day_field.value   = values[:date].strftime('%d') # .day gives '1' not '01'
      month_field.value = values[:date].strftime('%m')
      year_field.value  = values[:date].year
      @form.projectid   = "project.id='#{values[:project]}'"
      @form.remark      = values[:remark]
      @form.time        = values[:hours]

      # FIX
      @form.phaseid = "phase.id='276'"
    end

    def print_values
      format = "%10s: \"%s\"\n"
      printf format, 'day',     day_field.value
      printf format, 'month',   month_field.value
      printf format, 'year',    year_field.value
      printf format, 'project', selected_projectid_option.text
      printf format, 'remark',  @form.remark
      printf format, 'hours',   @form.time
      printf format, 'phase',   'leveranse' #FIX

      # @form.fields.each do |field|
      #   printf format, field.name, field.value
      # end

    end

    def submit
      @form.submit()
    end

    def flexi_time
      @page.body.match(/(Flexi time balance: -?\d+:\d+)/)
      $1
    end

    private

    def day_field
      @form.field_with(:name => 'activitydate[day]')
    end

    def month_field
      @form.field_with(:name => 'activitydate[month]')
    end

    def year_field
      @form.field_with(:name => 'activitydate[year]')
    end

    def selected_projectid_option
      @form.field_with(:name => 'projectid').options.each do |opt|
        return opt if opt.selected
      end
      return nil
    end
    
    def projects_url
      href = @page.link_with(:text => 'Select project').href['javascript:atkSubmit("__'.length..-3]
      href.gsub!('_13F', '?')
      href.gsub!('_13D', '=')
      href.gsub!('_126', '&')
      return RC[:url] + '/' + href
    end

    def scrape_projects(projects_page)
      projects = {}

      projects_page.search('table#rl_1 tr').each do |tr|
        cells = tr.search('td')
        next if cells.empty?
        projects[cells[1].text.strip] = cells[0].text.strip
        #FIX extract project id cells[1].css('a').attribute('href')
      end

      return projects
    end

  end
end
