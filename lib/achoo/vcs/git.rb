class Achoo; class VCS; end; end

class Achoo::VCS::Git

  def self.repository?(dir)
    File.exists?("#{dir}/.git")
  end

  def initialize(dir)
    @dir = dir
  end

  def log_for(date)
    today    = date.strftime('%Y-%m-%d')
    tomorrow = date.next.strftime('%Y-%m-%d')
    
    `cd  #@dir; git log --author=#{ENV['USER']} --oneline --after=#{today} --before=#{tomorrow} | cut -d ' ' -f 2-`
  end

end
