class Achoo; end

require 'achoo/subversion'
require 'achoo/git'

class Achoo::VCS

  def self.factory(dir)
    klass = [Achoo::Git, Achoo::Subversion].find do |k|
      k.repository?(dir)
    end
    return nil if klass.nil?
    klass.new(dir)
  end

  def self.print_log_for(date, vcs_dirs)
    vcs_dirs.each do |dir|
      Dir.glob("#{dir}/*/").each do |dir|
        vcs = factory(dir)
        if vcs.nil?
          puts "!!! Unrecognized vcs in dirctory: #{dir}"
        else
          vcs.print_log_for(date)
        end
      end
    end
  end

end
