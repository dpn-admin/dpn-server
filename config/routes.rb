# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


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
    resources :restore_transfers, only: [:index, :show, :create, :update, :destroy], path: :restore, param: :restore_id
    resources :members, only: [:index, :show, :create, :update, :destroy], path: :member, param: :uuid
  end
end
