Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, APP_CONFIG['twitter_consumer_key'], APP_CONFIG['twitter_consumer_secret']
  provider :facebook, APP_CONFIG['facebook_app_id'], APP_CONFIG['facebook_app_secret']
end