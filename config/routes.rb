Rails.application.routes.draw do
  resources :articles, only: :show
end
