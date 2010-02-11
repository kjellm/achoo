require 'rubygems'
require 'rake/gempackagetask' # Why do I need this?

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "Achievo CLI."
  s.name = 'achoo'
  s.version = '0.0.' << Time.now.strftime("%Y%m%d%H%M%S")
  s.author = 'Kjell-Magne Øierud'
  s.email = 'kjellm@acm.org'
  s.homepage = 'http://github.com/kjellm/achoo/'
  s.add_dependency('mechanize', '>= 1.0.0')
  s.requirements << 'none'
  s.files = FileList['lib/**/*.rb', 'achoo', 'README.rdoc', 'Rakefile', 'COPYING'].to_a
  s.description = 'Command line interface to Achievo'
  s.bindir = '.'
  s.executables << 'achoo'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
