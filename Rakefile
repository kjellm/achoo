# encoding: utf-8

require 'rake/testtask'
require 'rubygems'
require 'rubygems/package_task'

task :default => ['test:unit']

namespace 'build' do
  require "bundler/gem_tasks"
end

task :test => ['test:unit', 'test:acceptance']

namespace 'test' do

  Rake::TestTask.new do |t|
    t.name = :unit
    t.libs << "test/lib"
    t.test_files = FileList['test/unit/test*.rb']
  end

  # Need a fresh ruby interpreter for each acceptance test, so I can't
  # use Rake::TestTask
  task :acceptance do
    FileList['test/acceptance/test*.rb'].each do |f|
      ruby "-Ilib -Itest/lib #{f}"
    end
  end

end

