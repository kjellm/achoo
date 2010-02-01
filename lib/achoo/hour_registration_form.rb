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
      @form.field_with(:name => 'activitydate[day]') \
        .options[values[:date].day.to_i - 1].select

      @form.field_with(:name => 'activitydate[month]') \
        .options[values[:date].month.to_i - 1].select

      @form.field_with(:name => 'activitydate[year]').value \
        = values[:date].year

      @form.projectid = "project.id='#{values[:project]}'"

      @form.remark = values[:remark]

      @form.time = values[:hours]
    end

    def print_values
      printf "%10s: %s\n", 'day', @form.field_with(:name => 'activitydate[day]').value
      printf "%10s: %s\n", 'month', @form.field_with(:name => 'activitydate[month]').value
      printf "%10s: %s\n", 'year', @form.field_with(:name => 'activitydate[year]').value

      @form.field_with(:name => 'projectid').options.each do |opt|
        if opt.selected
          printf "%10s: '%s'\n", 'project', opt.text
        end
      end

      printf "%10s: '%s'\n", 'remark', @form.remark
      printf "%10s: %s\n", 'hours', @form.time
    end


    def submit
      require 'pp'
      response =  @form.submit()
      pp response.body
    end


    private

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
