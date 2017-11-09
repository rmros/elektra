# frozen_string_literal: true

SharedFilesystemStorage::Engine.routes.draw do
  root to: 'application#show', as: :start

  resources :shares, except: %i[new edit], constraints: { format: :json } do
    resources :rules, module: 'shares', except: %i[show new edit update]
    get :availability_zones, constraints: { format: :json }, on: :collection
    get :export_locations, constraints: { format: :json }, on: :member
  end
  resources :snapshots, except: %i[new edit], constraints: { format: :json }
  resources :security_services, except: %i[show new edit],
                                constraints: { format: :json },
                                path: 'security-services'

  resources :share_networks, except: %i[show new edit],
                             constraints: { format: :json },
                             path: 'share-networks' do
    resources :security_services, module: 'share_networks',
                                  except: %i[show new edit update],
                                  path: 'security-services'
    get :networks, constraints: { format: :json }, on: :collection
    get :subnets, constraints: { format: :json }, on: :collection
  end
end
