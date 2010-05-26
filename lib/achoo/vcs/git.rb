require 'achoo/vcs'

module Achoo
  class VCS
    class Git

      def self.repository?(dir)
        File.exists?("#{dir}/.git")
      end

      def initialize(dir)
        @dir = dir
      end
      
      def log_for(date)
        format = '%Y-%m-%dT00:00:00'
        from = date.strftime(format)
        to   = (date+1).strftime(format)
        
        cmd = "cd  #@dir; git log --author=#{ENV['USER']} --oneline --after=#{from} --before=#{to} | cut -d ' ' -f 2-"
        `#{cmd}`
      end

    end
  end
end
