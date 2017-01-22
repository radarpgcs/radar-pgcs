Rails.application.routes.draw do
  
  root 'application#index'
  get '/', to: 'application#index', as: 'home'
  get '/login', to: 'application#login', as: 'login'
  post '/authenticate', to: 'application#sign_in', as: 'sign_in'
end