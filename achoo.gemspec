# encoding: utf-8

Spec = Gem::Specification.new do |s|

  s.required_ruby_version = '>= 1.8.1'

  s.platform    = Gem::Platform::RUBY
  s.name        = 'achoo'
  s.version     = begin
                    v = '0.5.1'
                    origin_master_commits = `git rev-list origin/master`.split("\n")
                    v << '.' << origin_master_commits.length.to_s
                  end
  s.summary     = 'Achievo CLI.'
  s.description = 'Command line interface for Achievo (http://achievo.org)'
  s.homepage    = 'http://kjellm.github.com/achoo/'
  s.author      = 'Kjell-Magne Øierud'
  s.email       = 'kjellm@acm.org'

  s.add_dependency('mechanize', '>= 1.0.0')
  s.add_dependency('plugman',   '>= 0.1.1')
  s.add_dependency('ri_cal')
  s.requirements << 'none'

  s.files = Dir.glob('bin/*') + 
    Dir.glob('lib/**/*.rb') + 
    Dir.glob('test/**/*.rb') + 
    %w(Rakefile README.rdoc CHANGES COPYING)
  s.bindir = 'bin'
  s.executables = %w(achoo awake vcs_commits ical)

end

