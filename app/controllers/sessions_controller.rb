class SessionsController < ApplicationController
  def create
    user = env["omniauth.auth"]
    cred = user['credentials']

    twitter_name = user['info']['nickname'].downcase
    city = City.where( :twitter_username => twitter_name ).first
    city.twitter_access_token = cred['token']
    city.twitter_access_secret = cred['secret']
    city.save

    redirect_to root_url, notice: "Update Twitter Credentials for #{twitter_name}"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Signed out!"
  end
end