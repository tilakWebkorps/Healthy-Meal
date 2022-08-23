Rails.application.routes.draw do
  devise_for :users,
  controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
  }
  namespace :users do
    resources :users, path: '/', except: %i[create]
  end
end
