Rails.application.routes.draw do
  resources :sessions do
    get 'admin_new', on: :collection
  end
  resources :teams do 
    get 'admin_index', on: :collection
  end
end
