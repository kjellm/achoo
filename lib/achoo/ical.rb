require 'net/https'
require 'ri_cal'

require 'achoo/date_time_interval'

class Achoo; end

class Achoo::ICal

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

  def print_events(date)
    arg_start = date
    arg_end   = arg_start + 1

    @calendar.events.each do |e|
      if e.recurs? && e.occurrences({:overlapping => [arg_start, arg_end]})
        ; #FIX
      elsif e.dtstart > arg_start && e.dtstart < arg_end
        dti = Achoo::DateTimeInterval.new(e.dtstart.to_s, e.dtend.to_s)
        printf "%s: %s\n", dti, e.summary
      end
    end
  end
end

