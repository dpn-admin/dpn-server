Rails.application.routes.draw do
  namespace :api_v1 do
    resources :nodes, only: [:index, :show, :create, :update], path: :node, param: :namespace
    resources :bags, only: [:index, :show, :create, :update], path: :bag, param: :uuid
    resources :replication_transfers, only: [:index, :show, :create, :update], path: :repl
    resources :restore_transfers, only: [:index, :show, :create, :update], path: :restore
  end
end
