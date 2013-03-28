
LocalRead::Application.routes.draw do



  match '/s/:id', :controller => :shortened_urls, :action => :show, :as => :shortener
  #match '/s/:id', :to => "shortened_urls#show", :as => :shortener

  match "/*path" => redirect("http://www.placeling.com")

  root :to => redirect("http://www.placeling.com")

end
