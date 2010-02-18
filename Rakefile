require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

def version
  v = '0.2.0'
  origin_master_commits = `git rev-list origin/master`.split("\n")
  v << '.' << origin_master_commits.length.to_s
end


spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY

  s.name        = 'achoo'
  s.version     = version
  s.summary     = 'Achievo CLI.'
  s.description = 'Command line interface for Achievo (http://achievo.org)'
  s.homepage    = 'http://github.com/kjellm/achoo/'

  s.author = 'Kjell-Magne Øierud'
  s.email  = 'kjellm@acm.org'

  s.add_dependency('mechanize', '>= 1.0.0')
  s.requirements << 'none'
  s.files = FileList['bin/*',
                     'lib/**/*.rb', 
                     'test/*',
                     'Rakefile',
                     'README.rdoc',
                     'CHANGES',
                     'COPYING'].to_a
  s.bindir = 'bin'
  s.executables = %w(achoo awake vcs_commits)
  s.required_ruby_version = '>= 1.8.1'
end


Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end


Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  #t.verbose = true
end


# gem install allison
Rake::RDocTask.new do |rd|
  rd.title = 'Achoo --- The Achievo CLI'
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.template = `allison --path`.chop + '.rb'
  rd.options << '--line-numbers' << '--inline-source'
  rd.rdoc_dir = 'doc'
end
