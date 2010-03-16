require 'achoo/timespan'
require 'achoo/ui/exception_handling'
require 'net/https'
require 'ri_cal'

class Achoo; end

class Achoo::ICal

  Achoo::UI::ExceptionHandling

  def self.from_http_request(params)
    http = Net::HTTP.new(params[:host], params[:port])
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    ics = http.start do |http|
      request = Net::HTTP::Get.new(params[:path])
      request.basic_auth(params[:user], params[:pass])
      response = http.request(request)
      response.body
    end
    self.new(ics)
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
    dti = Achoo::Timespan.new(e.dtstart.to_s, e.dtend.to_s)
    io.printf "%s: %s\n", dti, e.summary
  end
end

