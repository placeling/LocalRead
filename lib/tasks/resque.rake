require 'resque/tasks'
require 'resque_scheduler/tasks'

task "resque:preload" => :environment

namespace :resque do
  task :setup => :environment do
    require 'resque'
    require 'resque_scheduler'
    require 'resque/scheduler'
    #Resque.before_first_fork = Proc.new { Rails.logger = RESQUE_LOGGER }
  end
end
