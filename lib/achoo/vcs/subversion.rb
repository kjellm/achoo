require 'achoo/vcs'
require 'nokogiri'

class Achoo::VCS::Subversion

  def self.repository?(dir)
    File.exist?("#{dir}/.svn")
  end

  def initialize(dir)
    @dir = dir
  end

  def log_for(date)
    date = date.strftime("%F")
    xml = Nokogiri::XML(`cd #@dir; svn log --xml`)
    logentries = xml.xpath("/log/logentry/author[contains(., \"#{ENV['USER']}\")]/parent::*")

    # FIX are the dates in the xml local time, or do they need to be
    # converted?
    log = ""
    logentries.each do |e|
      if e.css('date').text.start_with?(date)
        log << e.css('msg').text.strip << "\n"
      end
    end
    log
  end

  
end
