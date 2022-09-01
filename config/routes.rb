# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }
  namespace :users do
    resources :users, path: '/', except: %i[create]
  end
  resources :recipes, controller: 'restaurant/recipes'
  resources :plans, controller: 'restaurant/plans'
  root 'restaurant/plans#index'
  post 'users/:id/change_role', to: 'users/users#update'
  post 'users/:id/set_role', to: 'users/users#set_role'
  get 'restaurant/plans/active_users', to: 'restaurant/plans#active_users'
  get 'restaurant/plans/:id/buy', to: 'restaurant/plans#buy_plan', as: 'buy_plan'
  get 'restaurant/plans/:id/users_activated', to: 'restaurant/plans#users_activated'
  get 'restaurant/plans/:id/change_plan', to: 'restaurant/plans#change_plan'
  get '*path', to: 'application#routing_error'
  post '*path', to: 'application#routing_error'
end
