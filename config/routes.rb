Rails.application.routes.draw do
  root 'credentials#index'

  get '/credential', to: 'credentials#credential'

  get '/presentation', to: 'credentials#presentation'
end
