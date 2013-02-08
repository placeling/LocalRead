require 'resque/server'

LocalRead::Application.routes.draw do
  devise_for :subscribers

  post "/", :to => 'home#signup', :as => :signup
  get "/signup", :to => 'home#dead_signup', :as => :thanks


  match '/vanitystats(/:action(/:id(.:format)))', :controller => :vanity


  if Rails.env.development?
    mount WeeklyMailer::Preview => 'mail_view'
  end

  mount Resque::Server, :at => "/resque"

  root :to => "home#index"

end
