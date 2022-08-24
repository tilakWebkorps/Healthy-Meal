Rails.application.routes.draw do
  devise_for :users,
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  namespace :users do
    resources :users, path: '/', except: %i[create]
  end
  resources :recipes, controller: 'restaurant/recipes'
  resources :plans, controller: 'restaurant/plans'
  get 'restaurant/plans/:id/buy', to: 'restaurant/plans#buy_plan'
end