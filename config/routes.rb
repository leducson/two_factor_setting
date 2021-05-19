Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }
  resources :dashboard
  root to: "dashboard#index"
  resource :two_factor_settings, except: :index do
    collection do
      post :download
      post :confirm_password
      post :verify_otp
      get :generate_backup_code
    end
  end
end
