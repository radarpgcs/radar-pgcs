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
  get '/ativar-conta-usuario/:registry', to: 'application#activate_user', as: 'activate_user'
  post '/activate_user', to: 'application#activate_user_account', as: 'activate_user_account'

  get '/promocoes', to: 'promotions#index', as: 'promotions'
  get '/pesquisar-promocoes', to: 'promotions#find', as: 'find_promotions'
  get '/promocoes/:type/:staff/:year', to: 'promotions#list', as: 'list_promotions'

  get '/empregados/:registry', to: 'employees#show', as: 'show_employee'
end