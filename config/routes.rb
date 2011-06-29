Kanban::Application.routes.draw do
  resource :user_sessions
  
  resources :projects do
    resources :statistics
    resource :dashboard
    resource :backlog
    resource :livelog
    resources :lanes do
      resources :items do
        collection do
          post :dnd
        end

        resources :versions
        resources :comments
      end
    end
  end

  match '/' => 'user_sessions#new'
end