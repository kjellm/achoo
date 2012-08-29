# encoding: utf-8

$:.push File.expand_path("../lib", __FILE__)
require 'achoo/version'

Gem::Specification.new do |s|

  s.required_ruby_version = '>= 1.8.1'

  s.platform    = Gem::Platform::RUBY
  s.name        = 'achoo'
  s.version     = Achoo::VERSION
  s.summary     = 'Achievo CLI.'
  s.description = 'Command line interface for Achievo (http://achievo.org)'
  s.homepage    = 'http://kjellm.github.com/achoo/'
  s.author      = 'Kjell-Magne Øierud'
  s.email       = 'kjellm@acm.org'

  s.add_dependency('mechanize')
  s.add_dependency('ri_cal')
  s.add_dependency('plugman',   '~> 1.0')
  s.add_dependency('shellout',  '~> 0.4')

  s.requirements << 'none'

  s.files = Dir.glob('bin/*') + 
    Dir.glob('lib/**/*.rb') + 
    Dir.glob('test/**/*.rb') + 
    %w(Rakefile README.rdoc CHANGES COPYING)
  s.bindir = 'bin'
  s.executables = %w(achoo awake vcs_commits ical)
end
