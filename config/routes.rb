ActionController::Routing::Routes.draw do |map|
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  map.login 'login', :controller => 'sessions', :action => 'new'
  #map.resources :users

  map.resource :sessions

 	map.root :controller => "overview"
  
  # oauth
  map.resources :oauth_clients
  map.test_request  'oauth/test_request', :controller => 'oauth', :action => 'test_request'
  map.access_token  'oauth/access_token', :controller => 'oauth', :action => 'access_token'
  map.request_token 'oauth/request_token', :controller => 'oauth', :action => 'request_token'
  map.authorize     'oauth/authorize', :controller => 'oauth', :action => 'authorize'
  map.oauth         'oauth', :controller => 'oauth', :action => 'index'

  # api
  map.connect 'api/:action/:api_action.:format', :controller => 'api' 
  map.connect 'api/:action/:api_action/:id', :controller => 'api'
  map.connect 'api/:action/:api_action/:id.format', :controller => 'api'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
