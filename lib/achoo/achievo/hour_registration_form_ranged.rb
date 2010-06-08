require 'achoo/achievo'

module Achoo
  module Achievo
    class HourRegistrationFormRanged < HourRegistrationForm

      include Achievo::DateField('to_date', 'todate')

      def initialize(agent)
        super
        @page = @agent.get(atk_submit_to_url(@page.link_with(:text => 'Select range').href))
        @form = @page.form('entryform')

        # Need to preselect this for some reason. FIX duplicated in super 
        @form.field_with(:name => 'billpercent').options.first.select
      end

      def date=(date_range)
        super(date_range[0])
        self.to_date = date_range[1]
      end

      def date
        [super, to_date()]
      end
      
      private

      def date_to_s
        date.map {|d| d.strftime("%Y-%m-%d")}.join(" -> ")
      end
      
    end
  end
end
