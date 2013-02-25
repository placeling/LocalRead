require 'resque/server'

LocalRead::Application.routes.draw do
  get "issues/show"

  get "issues/index"

  devise_for :subscribers,
             :controllers => { :confirmations => "subscribers/confirmations"}

  post "/", :to => 'home#signup', :as => :signup
  get "/signup", :to => 'home#dead_signup', :as => :thanks
  get "/confirmed", :to => "home#confirmed", :as => :confirmed
  get "/unsubscribe", :to => "home#unsubscribe", :as => :unsubscribe
  get "/resubscribe", :to => "home#resubscribe", :as => :resubscribe

  get "/vancouver", :to => 'home#city', :as => :city, :lat =>  "49.261226", :lng => "-123.1139268"

  match '/vanitystats(/:action(/:id(.:format)))', :controller => :vanity


  #if Rails.env.development?
    mount WeeklyMailer::Preview => 'mail_view'
  #end

  resources :cities, :only => [:show] do
    resources :issues
  end

  mount Resque::Server, :at => "/resque"

  root :to => "home#index"

end
