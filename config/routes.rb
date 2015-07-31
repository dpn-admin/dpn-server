Rails.application.routes.draw do
  root to: "rails_admin/main#index"

  # Devise routes
  # We don't skip anything because registration and recovery
  # are disabled in devise (see the migration and the user model)
  devise_for :users

  # RailsAdmin routes
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'


  namespace :api_v1, path: :"api-v1" do
    resources :nodes, only: [:index, :show, :create, :update, :destroy], path: :node, param: :namespace
    put "/node/:namespace/auth_credential", controller: :nodes, action: :update_auth_credential
    resources :bags, only: [:index, :show, :create, :update, :destroy], path: :bag, param: :uuid
    resources :replication_transfers, only: [:index, :show, :create, :update, :destroy], path: :replicate, param: :replication_id
    put "/replicate/:id/set_bag_man_request", controller: :replication_transfers, action: :set_bag_man_request
    resources :restore_transfers, only: [:index, :show, :create, :update, :destroy], path: :restore, param: :restore_id

    namespace :bag_man do
      put "/requests/:id/downloaded", controller: :requests, action: :downloaded
      put "/requests/:id/unpacked", controller: :requests, action: :unpacked
      put "/requests/:id/fixity", controller: :requests, action: :fixity
      put "/requests/:id/validity", controller: :requests, action: :validity
      put "/requests/:id/preserved", controller: :requests, action: :preserved
      put "/requests/:id/cancel", controller: :requests, action: :cancel
      resources :requests, only: [:index, :show, :create, :destroy], path: :requests
    end
  end
end
