class Achoo::Git

  def self.git_repository?(dir)
    File.exist?("#{dir}/.git")
  end

  def initialize(dir)
    @dir = dir
  end

  def print_log_for(date)
    today    = date.strftime('%Y-%m-%d')
    tomorrow = date.next.strftime('%Y-%m-%d')
    
    output = `cd  #@dir; git log --author=#{ENV['USER']} --oneline --after=#{today} --before=#{tomorrow}| cut -d ' ' -f 2-`
    puts "---------(#@dir)-------------" unless output == ''
    print output
  end

end
