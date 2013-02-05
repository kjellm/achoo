require 'achoo/achievo'
require 'achoo/term'
require 'achoo/ui'
require 'readline'

module Achoo
  module UI
    module RegisterHours

      include DateChoosers
      include ExceptionHandling

      def initialize
      end

      def register_hours
        date = optionally_ranged_date_chooser
        
        puts "Fetching data ..."
        form = if date.class == Array
                 Achievo::HourRegistrationFormRanged
               else
                 Achievo::HourRegistrationForm
               end.new
        
        form.date    = date
        form.project = project_chooser(form)
        form.phase   = phase_chooser(form)
        PLUGINS.notify(:before_register_hour_remark, date) unless date.class == Array
        form.remark  = remark_chooser
        PLUGINS.notify(:before_register_hour_hours, date) unless date.class == Array
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

        date
      end
      

      def phase_chooser(form)
        chooser_helper(form.phases_for_selected_project,
                       "Phases",
                       'Phase')
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

      def remark_chooser
        Term::ask 'Remark'
      end


      def project_chooser(form)
        puts 'Recently used projects'
        projects = form.recent_projects
        answer = Term.choose('Project [1]', projects.collect { |p| p[1] },
                             'Other', [''])
        return all_projects_chooser(form) if projects.empty?
        return case answer
               when '0'
                 all_projects_chooser(form)
               when ''
                 projects[0][0]
               else
                 projects[answer.to_i-1][0]
               end
      end

      
      
      def all_projects_chooser(form)
        projects = form.all_projects

        p projects

        # FIX move readline stuff to the term modules
        original_readline_comp_proc = Readline.completion_proc
        original_readline_comp_append_char = Readline.completion_append_character
        Readline.completion_append_character = ''
        Readline.completion_proc = proc do |s|
          projects.collect {|p| p[1] }.grep(/^#{Regexp.escape(s)}/)
        end


        answer = chooser_helper(projects, 
                                'All projects', 
                                'Project')

        Readline.completion_proc = original_readline_comp_proc
        Readline.completion_append_character = original_readline_comp_append_char

        answer
      end

      def chooser_helper(options, heading, prompt, empty_allowed=false)
        puts heading

        extra = empty_allowed ? [''] : []
        project_names = options.collect {|p| p[1] }
        if heading == 'All projects'
          # FIX ugly conditional
          extra += project_names
        end
        answer = Achoo::Term.choose(prompt, options.collect {|p| p[1] }, nil, extra)
        answer = '1' if answer.empty?
        if heading == 'All projects'
          # FIX ugly conditional
          if answer =~ /^\d+$/
            index = answer.to_i
          else
            index = project_names.find_index(answer) + 1
          end
          answer = index unless index.nil?
        end
        options[answer.to_i-1][0]
      end

    end
  end
end
