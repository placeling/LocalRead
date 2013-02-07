require 'resque/server'

LocalRead::Application.routes.draw do
  devise_for :subscribers

  post "/", :to => 'home#signup', :as => :signup
  get "/signup", :to => 'home#dead_signup', :as => :thanks


  match '/vanitystats(/:action(/:id(.:format)))', :controller => :vanity

  root :to => "home#index"

  mount Resque::Server, :at => "/resque"
end
