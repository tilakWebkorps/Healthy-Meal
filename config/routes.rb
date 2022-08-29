# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
  namespace :users do
    resources :users, path: '/', except: %i[create]
  end
  resources :recipes, controller: 'restaurant/recipes'
  resources :plans, controller: 'restaurant/plans'
  root 'restaurant/plans#index'
  get 'restaurant/plans/:id/buy', to: 'restaurant/plans#buy_plan', as: 'buy_plan'
  post 'users/:id/change_role', to: 'users/users#update'
  get 'restaurant/plans/:id/users_activated', to: 'restaurant/plans#users_activated'
  get 'restaurant/plans/active_users', to: 'restaurant/plans#active_users'
  get '*path', to: 'application#routing_error'
  post '*path', to: 'application#routing_error'
end
