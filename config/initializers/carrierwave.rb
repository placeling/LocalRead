require 'carrierwave/mongoid'

CarrierWave.configure do |config|
  config.fog_public = true # optional, defaults to true
  config.fog_attributes = {'Cache-Control' => 'max-age=315576000'} # optional, defaults to {}
  config.fog_credentials = {
      :provider => 'AWS', # required
      :aws_access_key_id => APP_CONFIG['amazon_access_key_id'], # required
      :aws_secret_access_key => APP_CONFIG['amazon_secret_access_key'], # required
      :persistent => false # This is required to prevent write timeouts from PUT requests to S
  }

  if Rails.env.production?
    config.fog_directory = 'localread-production' # required
  else
    config.fog_directory = 'localread-test' # required
  end

end