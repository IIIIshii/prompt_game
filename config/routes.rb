Rails.application.routes.draw do
  root "days#index"
  resources :days, only: [ :index, :show, :create ] do
    member do
      get :play
      post :next_turn
      get :entry
    end
  end
  get "*path", to: "application#render_404"
end
