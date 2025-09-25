Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      resources :products do
        collection do
          get :filter
          get :sort
          get :paginate
        end
      end
      resources :product_categories
      resources :product_types do
        collection do
          get :filter
          get :sort
          get :paginate
        end
      end
      resources :locations do
        collection do
          get :filter
          get :sort
          get :paginate
        end
      end
      resources :assets do
        collection do
          get :filter
          get :sort
          get :paginate
        end
      end
      resources :edge_devices do
        collection do
          get :filter
          get :sort
          get :paginate
        end
      end
      resources :passive_rfids do
        collection do
          get :filter
          get :sort
          get :paginate
        end
      end
      resources :asset_provisions do
        collection do
          get :filter
          get :sort
          get :paginate
        end
      end
    end
  end
end
