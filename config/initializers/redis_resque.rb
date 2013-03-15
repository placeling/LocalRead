require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'resque_scheduler'
require 'resque_scheduler/server'

REDIS_CONFIG = YAML.load(File.open(Rails.root.join("config/redis.yml")))[Rails.env] #opened in application.rb

redis_base = Redis.new(REDIS_CONFIG.symbolize_keys!)

Resque.redis = redis_base
Resque.redis.namespace = "resque:tlr"


unless defined?(RESQUE_LOGGER)
  f = File.open("#{Rails.root}/log/resque.log", 'a+')
  f.sync = true
  RESQUE_LOGGER = ActiveSupport::BufferedLogger.new f
end

Resque.schedule = YAML.load_file(File.join(Rails.root, 'config/resque_schedule.yml'))

$redis = Redis::Namespace.new(REDIS_CONFIG[:namespace], :redis => redis_base)
$redis.flushdb if Rails.env.test?


Resque::Server.use Rack::Auth::Basic do |username, password|
  password == "queueitup"
end
