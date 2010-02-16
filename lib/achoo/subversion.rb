require 'nokogiri'

class Achoo; end

class Achoo::Subversion

  def self.repository?(dir)
    File.exist?("#{dir}/.svn")
  end

  def initialize(dir)
    @dir = dir
  end

  def print_log_for(date)
    date = date.strftime("%F")
    xml = Nokogiri::XML(`cd #@dir; svn log --xml`)
    logentries = xml.xpath("/log/logentry/author[contains(., \"#{ENV['USER']}\")]/parent::*")
    log = ""
    logentries.each do |e|
      if e.css('date').text.start_with?(date)
        log << e.css('msg').text
      end
    end
    puts "---------(#@dir)-------------" unless log.empty?
    puts log

  end

  
end
