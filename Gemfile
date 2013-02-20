source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem "capistrano"
gem 'rvm-capistrano'

gem "aws-ses",:require => 'aws/ses'

gem 'vanity'

gem "airbrake"

gem 'httparty'

group :test, :development do
  gem "quiet_assets", ">= 1.0.1"
end

gem 'mail_view', :git => 'https://github.com/37signals/mail_view.git'

gem "actionmailer_inline_css"
gem "instagram"


gem "foreman", "~> 0.60.2"
gem "redis", "~> 2.2"
gem "redis-namespace"
gem 'redis-rails'
gem 'resque', :require => 'resque/server'
gem 'resque_mailer'


gem 'mini_magick'
gem 'carrierwave'
gem 'fog'
gem 'carrierwave-mongoid'
gem 'uuidtools'

gem "therubyracer", "0.11.1"
gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem "twitter-bootstrap-rails"


gem 'bson_ext'
gem "mongo"
gem "mongoid", ">= 3.0.15"
gem "rspec-rails", ">= 2.11.4", :group => [:development, :test]
gem "database_cleaner", ">= 0.9.1", :group => :test
gem "mongoid-rspec", ">= 1.5.5", :group => :test
gem "email_spec", ">= 1.4.0", :group => :test
gem "factory_girl_rails", ">= 4.1.0", :group => [:development, :test]
gem "devise", ">= 2.1.2"
gem "figaro", ">= 0.5.0"

gem "devise-async"