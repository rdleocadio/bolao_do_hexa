Rails.application.routes.draw do
  get 'contact/index'
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  root "pages#home"

  get "regras", to: "pages#rules", as: :rules
  get "privacidade", to: "pages#privacy", as: :privacy
  get "termos", to: "pages#terms", as: :terms
  get "contato", to: "contact#index", as: :contact

  resources :leagues, only: [:index, :show, :new, :create, :edit, :update] do
    member do
      post :join
    end

    collection do
      get :discover
      post :join_by_code
    end
  end

  resources :league_memberships, only: [] do
    member do
      patch :approve
      patch :reject
      delete :remove
    end
  end

  resources :matches, only: [:index]
  resources :predictions, only: [:create, :update, :destroy]
  resources :users, only: [:show]
  resources :standings, only: [:index]
  resources :brackets, only: [:index]

  namespace :admin do
    resources :matches, only: [:index, :new, :create, :edit, :update, :destroy] do
      member do
        patch :lock_now
        patch :reopen
      end

      collection do
        get :bulk_new
        post :bulk_create
        get :bulk_edit
        patch :bulk_update
        delete :bulk_destroy
      end
    end

    resources :group_standing_overrides, only: [:index, :edit, :update] do
      collection do
        post :generate
        delete :reset
      end
    end
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
