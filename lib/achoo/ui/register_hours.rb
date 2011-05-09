require 'achoo/achievo'
require 'achoo/awake'
require 'achoo/ical'
require 'achoo/term'
require 'achoo/ui'
require 'achoo/vcs'

module Achoo
  module UI
    module RegisterHours

      include DateChoosers
      include ExceptionHandling

      def register_hours(agent)
        date = optionally_ranged_date_chooser
        
        puts "Fetching data ..."
        form = if date.class == Array
                 Achievo::HourRegistrationFormRanged
               else
                 Achievo::HourRegistrationForm
               end.new(agent)
        
        form.date    = date
        form.project = project_chooser(form)
        form.phase   = phase_chooser(form)
        print_remark_help(date) unless date.class == Array
        form.remark  = remark_chooser
        print_hours_help(date) unless date.class == Array
        form.hours   = hours_chooser
        
        answer = Term.ask("Do you want to change the defaults for worktime period and/or billing percentage? [N/y]").downcase
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
        chooser_helper(form.phases_for_selected_project,
                       "Phases",
                       'Phase')
      end


      def print_hours_help(date)
        puts "Awake log:"
        begin
          awake = Awake.new
          awake.at(date)
          puts
        rescue Exception => e
          print handle_exception("Failed to retrieve awake log.", e)
        end
      end

      def hours_chooser
        answer = Term::ask 'Hours [7:30]'
        return answer == '' ? '7.5' : answer
      end

      def workperiod_chooser(form)
        chooser_helper(form.worktime_periods,
                       "Worktime periods",
                       'Period [1]',
                       true)
      end

      def billing_chooser(form)
        chooser_helper(form.billing_options,
                       "Billing options", 
                       'Billing [1]',
                       true)
      end

      def print_remark_help(date)
        puts "VCS logs for #{date}:"
        begin
          VCS.print_logs_for(date, RC[:vcs_dirs])
        rescue Exception => e
          puts handle_exception("Failed to retrieve VCS logs.", e)
        end
        puts '-' * 80
      end

      def remark_chooser
        Term::ask 'Remark'
      end


      def project_chooser(form)
        puts 'Recently used projects'
        projects = form.recent_projects
        answer = Term.choose('Project [1]', projects.collect { |p| p[1] },
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
        chooser_helper(form.all_projects, 
                       'All projects', 
                       'Project')
      end

      def chooser_helper(options, heading, prompt, empty_allowed=false)
        puts heading
        extra = empty_allowed ? [''] : []
        answer = Achoo::Term.choose(prompt, options.collect {|p| p[1] }, nil, [''])
        answer = '1' if answer.empty?
        options[answer.to_i-1][0]
      end

    end
  end
end
