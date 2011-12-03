# encoding: utf-8

require 'rake/testtask'
require 'rubygems'
require 'rubygems/package_task'

load File.dirname(__FILE__) + '/achoo.gemspec'

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

namespace 'metrics' do

  begin
    require 'code_stats'
    CodeStats::Tasks.new
  rescue LoadError => e
    warn "Package code_stats required for the metrics:code_stats task to be available."
  end

  desc 'Measures test coverage'
  task :coverage do
    rm_f('coverage')
    system("rcov -T -Ilib:test/lib test/unit/test_*.rb")
  end

end


begin
  require 'metric_fu'
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
rescue LoadError => e
  warn "Package metric_fu required for the metrics:all task to be available."
end


namespace 'doc' do

  begin 
    require 'hanna/rdoctask'
  rescue LoadError => e
    warn "Package hanna recommended for better rdoc output."
    require 'rake/rdoctask'
  end
  Rake::RDocTask.new do |rd|
    rd.title = 'Achoo --- The Achievo CLI'
    rd.main = "README.rdoc"
    rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
    rd.options << '--line-numbers' << '--inline-source'
    rd.rdoc_dir = 'doc'
  end
end


desc 'Remove generated files and folders'
task :clean => ['build:clobber_package', 'doc:clobber_rdoc']
