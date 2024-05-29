AgentMonitoring::Engine.routes.draw do
  resources :agents do
    get :auto_complete_search, on: :collection
  end

  namespace :api do
    namespace :v2 do
      resources :agents
    end
  end
end

Foreman::Application.routes.draw do
  mount AgentMonitoring::Engine, at: '/agent_monitoring'
end
