Rails.application.routes.draw do
  resources :sessions do
    collection do
      get 'admin_new'
      post 'klik'
    end    
    post 'test_klik', on: :member
  end
  resources :teams do 
    get 'admin_index', on: :collection
  end

  root to: 'teams#index'

  get 'api/v1/leaderboard', to: 'teams#index', defaults: { format: :json }
  post 'api/v1/klik', to: 'sessions#klik', defaults: { format: :json }

end
