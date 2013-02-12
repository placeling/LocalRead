
begin
  APP_CONFIG = YAML.load_file("/etc/localread/app_config.yml")[Rails.env]
rescue
  APP_CONFIG = YAML.load_file("#{Rails.root}/config/app_config.yml")[Rails.env]
end