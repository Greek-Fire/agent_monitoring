AgentMonitoring::Engine.routes.draw do
  get 'agents', to: 'agents#index', as: 'agents'
end

Foreman::Application.routes.draw do
  mount AgentMonitoring::Engine, at: '/agent_monitoring'
end
