require 'achoo'

module Achoo
  class VCS

    autoload :Git,        'achoo/vcs/git'
    autoload :Subversion, 'achoo/vcs/subversion'
    
    LINE_LENGTH = 80

    def self.factory(dir)
      klass = [Git, Subversion].find do |k|
        k.repository?(dir)
      end
      return nil if klass.nil?
      klass.new(dir)
    end

    def self.print_logs_for(date, vcs_dirs, io=$stdout)
      vcs_dirs.each do |dir|
        Dir.glob("#{dir}/*/").each do |dir|
          vcs = factory(dir)
          next if vcs.nil?

          log = vcs.log_for(date)
          print_log(log, dir, io)
        end
      end
    end

    private

    def self.print_log(log, dir, io)
      return if log.empty?
      io.puts header(dir)
      io.puts log.chomp
    end

    def self.header(dir)
      name = File.basename(dir).upcase
      name << ' '
      name << '-' * (LINE_LENGTH - name.length)
    end

    def self.fancy_header(dir)
      project = "<( #{File.basename(dir).upcase} )>"
      dashes = '-' * ((LINE_LENGTH - project.length) / 2)
      dashes + project + dashes
    end
  end
end
