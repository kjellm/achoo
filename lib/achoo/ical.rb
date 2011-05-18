require 'achoo'
require 'achoo/temporal'
require 'achoo/ui'
require 'net/https'
require 'ri_cal'
require 'uri'

module Achoo
  class ICal

    include UI::ExceptionHandling

    @@cache = {}

    def self.from_http_request(params)
      return @@cache[params] if @@cache[params]
      
      url = URI.parse(params[:url])

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      ics = http.start do |http|
        request = Net::HTTP::Get.new(url.path)
        request.basic_auth(params[:user], params[:pass])
        response = http.request(request)
        raise response.message unless response.is_a?(Net::HTTPSuccess)
        response.body
      end
    
      @@cache[params] = self.new(ics)
    end

    def initialize(ics_str)
      @calendar = RiCal.parse_string(ics_str).first
    end

    def print_events(date, io=$stdout)
      arg_start = date
      arg_end   = date + 1

      @calendar.events.each do |e|
        begin
          if !e.x_properties['X-MICROSOFT-CDO-ALLDAYEVENT'].empty? && e.x_properties['X-MICROSOFT-CDO-ALLDAYEVENT'].first.value == 'TRUE'
            # FIX handle this
          elsif e.recurs?
            e.occurrences({:overlapping => [arg_start, arg_end]}).each do |o|
              print_event(o, io)
            end
          elsif e.dtstart >= arg_start && e.dtstart <= arg_end \
            || e.dtend  >= arg_start && e.dtend <= arg_end
            print_event(e, io)
          end
        rescue Exception => e
          handle_exception("Failed to process calendar event", e)
        end
      end
    end

    private
    
    def print_event(e, io)
      dti = Temporal::Timespan.new(e.dtstart.to_s, e.dtend.to_s)
      io.printf "%s: %s\n", dti, e.summary
    end

  end
end

