Spec = Gem::Specification.new do |s|

  s.required_ruby_version = '>= 1.8.1'

  s.platform    = Gem::Platform::RUBY
  s.name        = 'achoo'
  s.version     = '0.3'
  s.summary     = 'Achievo CLI.'
  s.description = 'Command line interface for Achievo (http://achievo.org)'
  s.homepage    = 'http://github.com/kjellm/achoo/'
  s.author      = 'Kjell-Magne Øierud'
  s.email       = 'kjellm@acm.org'

  s.add_dependency('mechanize', '>= 1.0.0')
  s.add_dependency('ri_cal')
  s.requirements << 'none'

  s.files = Dir.glob('bin/*') + 
    Dir.glob('lib/**/*.rb') + 
    Dir.glob('test/*') + 
    %w(Rakefile README.rdoc CHANGES COPYING)
  s.bindir = 'bin'
  s.executables = %w(achoo awake vcs_commits ical)

end

