Rails.application.routes.draw do
  root "days#index"
  resources :days, only: [ :index, :show, :create ] do
    member do
      get :play
      post :next_turn
      get :entry
    end
  end

  namespace :admin do
    resources :days, only: [ :index ] do
      member do
        patch :toggle_status
      end
    end
  end

  # Active Storageのルートを除外して404を返す
  get "*path", to: "application#render_404", constraints: lambda { |req| !req.path.start_with?("/rails/active_storage") }
end
