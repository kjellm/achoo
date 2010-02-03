require 'achoo/form'

class Achoo
  class HourRegistrationForm < Achoo::Form

    PHASE_MAP = {
        "3"   => "Ferie",
        "4"   => "Permisjon med lønn",
        "5"   => "Permisjon uten lønn",
        "6"   => "Sykemelding",
        "9"   => "Helligdag",
        "276" => "Leveranse",
        "459" => "Foreldrepermisjon",
        "476" => "Egenmelding - barns sykdom",
        "477" => "Egenmelding - egen sykdom",
    }

    def initialize(agent)
      @agent = agent
      @page  = @agent.get(RC[:hour_registration_url])
      @form  = @page.form('entryform')
    end

    def project
      @form.projectid.match(/project\.id='(\d+)'/)[1]
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



    def phases_for_project
      # FIX make this work:
      # old_action = @form.action
      # @form.action = RC[:url]+"/dispatch.php?atknodetype=timereg.hours&atkaction=add&atkfieldprefix=&atkpartial=attribute.phaseid.refresh&atklevel=-3&atkprevlevel=0&atkstackid=4b67cdb34ff5a&"
      # p old_action
      # p @form.action
      # require 'logger'
      # @agent.log =  Logger.new("mech.log")
      # page = @form.submit(nil, {
      #   'X-Requested-With'    => 'XMLHttpRequest',
      #   'X-Prototype-Version' => '1.5.0_rc1'
      # })
      # @agent.log = nil
      # File.open("dump.html", "w") do |f|
      #   f.puts page.body
      # end
      # @form.action = old_action
      # p @form.action

      # Hard coded for now :(
      if (project == '1')
        [
         ["476", "Egenmelding - barns sykdom"],
         ["477", "Egenmelding - egen sykdom"],
         ["3",   "Ferie"],
         ["459", "Foreldrepermisjon"],
         ["9",   "Helligdag"],
         ["4",   "Permisjon med lønn"],
         ["5",   "Permisjon uten lønn"],
         ["6",   "Sykemelding"],
        ]
      else
        [["276", "Leveranse"]]
      end

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
        printf "%6s - %s: %s\n", projects[name][0], projects[name][1], name
      end
    end

    def print_values
      format = "%10s: \"%s\"\n"
      printf format, 'day',     day_field.value
      printf format, 'month',   month_field.value
      printf format, 'year',    year_field.value
      printf format, 'project', project
      printf format, 'phase',   PHASE_MAP[phase]
      printf format, 'remark',  @form.remark
      printf format, 'hours',   @form.time

      # @form.fields.each do |field|
      #   printf format, field.name, field.value
      # end

    end

    def submit
      require 'logger'
      @agent.log =  Logger.new("mech.log")
      @form.submit()
      @agent.log = nil
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

    def projects_url
      href = @page.link_with(:text => 'Select project').href['javascript:atkSubmit("__'.length..-3]
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
end
