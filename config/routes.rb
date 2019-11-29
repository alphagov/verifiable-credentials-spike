Rails.application.routes.draw do
  root 'application#index'

  get '/issue/', to: 'credentials#index'

  get '/issue/:type', to: 'credentials#issue'

  get '/issue/jwt/:type', to: 'credentials#issue_jwt'
end
