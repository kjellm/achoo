# encoding: utf-8

require 'code_stats'
require 'metric_fu'
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

end

namespace 'metrics' do

  CodeStats::Tasks.new

  desc 'Measures test coverage'
  task :coverage do
    rm_f('coverage')
    system("rcov -T -Ilib:test/lib test/unit/test_*.rb")
  end

end


MetricFu::Configuration.run do |config|
  dirs = %w(lib bin)

  # Define which metrics you want to use.
  # [:churn, :saikuro, :stats, :flog, :flay, :reek, :roodi, :rcov]
  #  - :stats only works for rails applications
  config.metrics  = [:churn, :saikuro, :flog, :flay, :reek, :roodi, :rcov] 

  # [:flog, :flay, :reek, :roodi, :rcov]
  config.graphs   = [:flog, :flay, :reek, :roodi, :rcov] 

  config.flay     = { 
    :dirs_to_flay  => dirs,
    :minimum_score => 0,
  } 
  config.flog     = { :dirs_to_flog  => dirs  }
  config.reek     = { :dirs_to_reek  => dirs  }
  config.roodi    = { :dirs_to_roodi => dirs }
  config.saikuro  = { 
    :output_directory => 'scratch_directory/saikuro', 
    :input_directory  => dirs,
    :cyclo            => "",
    :filter_cyclo     => "0",
    :warn_cyclo       => "5",
    :error_cyclo      => "7",
    :formater         => "text"  #this needs to be set to "text"
  }
  config.churn    = { 
    :start_date => "1 year ago", 
    :minimum_churn_count => 10
  }
  config.rcov     = { 
    :environment => '',
    :test_files => ['test/unit/**/test_*.rb'],
    :rcov_opts => ["--sort coverage", 
                   "--no-html", 
                   "--text-coverage",
                   "--no-color",
                   "--profile",
                   "--exclude /gems/,/test/",
                   "--include lib:test/lib",
                  ]}

  # :bluff or :gchart
  config.graph_engine = :bluff
end


namespace 'doc' do

  Rake::RDocTask.new do |rd|
    rd.title = 'Achoo --- The Achievo CLI'
    rd.main = "README.rdoc"
    rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
    rd.template = `allison --path`.chop + '.rb'
    rd.options << '--line-numbers' << '--inline-source'
    rd.rdoc_dir = 'doc'
  end

end

desc 'Install development dependencies'
task :setup do
  system 'gem install shoulda rack thin redgreen allison metric_fu code_stats'
end

desc 'Remove generated files and folders'
task :clean => ['build:clobber_package', 'doc:clobber_rdoc']
