Rails.application.routes.draw do
  namespace :api_v1 do
    resources :nodes, only: [:index, :show, :create, :update], path: :node, param: :namespace
    resources :bags, only: [:index, :show, :create, :update], path: :bag, param: :uuid
    resources :replication_transfers, only: [:index, :show, :create, :update], path: :repl, param: :replication_id
    resources :restore_transfers, only: [:index, :show, :create, :update], path: :restore, param: :restore_id

    namespace :bag_mgr do
      put "/requests/:id/downloaded", controller: :requests, action: :downloaded
      put "/requests/:id/unpacked", controller: :requests, action: :unpacked
      put "/requests/:id/fixity", controller: :requests, action: :fixity
      put "/requests/:id/validity", controller: :requests, action: :validity
      put "/requests/:id/preserved", controller: :requests, action: :preserved
      put "/requests/:id/cancel", controller: :requests, action: :cancel
      resources :requests, only: [:index, :show, :create], path: :requests
    end
  end
end
