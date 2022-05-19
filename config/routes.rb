# frozen_string_literal: true

Rails.application.routes.draw do
  root 'simulation#index'
  get 'simulation', to: 'simulation#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
