module AgentMonitoring
  class AgentsController < ApplicationController
    include Foreman::Controller::AutoCompleteSearch
    
    def index
      @agents = Agent.fetch(params)
    end
  end
end
