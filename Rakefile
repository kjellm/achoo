# encoding: utf-8

require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rubygems'

load File.dirname(__FILE__) + '/achoo.gemspec'

task :default => ['test:unit']

namespace 'build' do

  Rake::GemPackageTask.new(Spec) do |pkg|
    pkg.need_tar = true
  end

end

Rake::TestTask.new do |t|
  t.libs << "test/lib"
  t.test_files = FileList['test/**/test*.rb']
  #t.verbose = true
end

namespace 'test' do

  Rake::TestTask.new do |t|
    t.name = :unit
    t.libs << "test/lib"
    t.test_files = FileList['test/unit/test*.rb']
  end

  Rake::TestTask.new do |t|
    t.name = :acceptance
    t.libs << "test/lib"
    t.test_files = FileList['test/acceptance/test*.rb']
  end

  desc 'Measures test coverage'
  task :coverage do
    rm_f('coverage')
    system("rcov -T -Ilib test/unit/test_*.rb")
  end

end

namespace 'doc' do

  Rake::RDocTask.new do |rd|
    rd.title = 'Achoo --- The Achievo CLI'
    rd.main = "README.rdoc"
    rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
    rd.template = `allison --path`.chop + '.rb'             # gem install allison
    rd.options << '--line-numbers' << '--inline-source'
    rd.rdoc_dir = 'doc'
  end

end

