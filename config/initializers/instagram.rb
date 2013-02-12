
#https://github.com/Instagram/instagram-ruby-gem
Instagram.configure do |config|
  config.client_id = APP_CONFIG['instagram_client_id']
  config.client_secret = APP_CONFIG['instagram_client_secret']
end