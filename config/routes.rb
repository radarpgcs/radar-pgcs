Rails.application.routes.draw do
  
  root 'application#index'
  get '/', to: 'application#index', as: 'home'
  get '/login', to: 'application#login', as: 'login'
  post '/authenticate', to: 'application#sign_in', as: 'sign_in'
  delete '/logout', to: 'application#sign_out', as: 'signout'
  get '/news', to: 'application#news', as: 'news'
  get '/faq', to: 'application#faq', as: 'faq'
  get '/contato', to: 'application#contact', as: 'contact'
  post '/send_email', to: 'application#send_email', as: 'send_email'
end