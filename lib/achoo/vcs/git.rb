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
        
        cmd = "cd  #@dir; git log --all --author=#{ENV['USER']} --format=' - %s' --after=#{from} --before=#{to}"
        lines = `#{cmd}`
        word_wrap(lines)
      end
      
      private

      def word_wrap(lines)
        lines.each_line.collect do |l|
          l.gsub(/.{1,77}(?:\s|\Z)/){$&+"\n   "}.rstrip
        end.join("\n")
      end

    end
  end
end
