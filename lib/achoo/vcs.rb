class Achoo; end

require 'achoo/subversion'
require 'achoo/git'

class Achoo::VCS

  LINE_LENGTH = 80

  def self.factory(dir)
    klass = [Achoo::Git, Achoo::Subversion].find do |k|
      k.repository?(dir)
    end
    return nil if klass.nil?
    klass.new(dir)
  end

  def self.print_logs_for(date, vcs_dirs)
    vcs_dirs.each do |dir|
      Dir.glob("#{dir}/*/").each do |dir|
        vcs = factory(dir)
        if vcs.nil?
          puts "!!! Unrecognized vcs in dirctory: #{dir}"
          next
        end

        log = vcs.log_for(date)
        print_log(log, dir)
      end
    end
  end

  def self.print_log(log, dir)
    unless log.empty?
      project = "<( #{File.basename(dir).upcase} )>"
      dashes = '-' * ((LINE_LENGTH - project.length) / 2)
      puts dashes + project + dashes
      puts log.chomp
    end
  end

end
