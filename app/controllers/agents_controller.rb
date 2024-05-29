module AgentMonitoring
  class AgentsController < ApplicationController
    def index
      @agents = Agent.fetch(params)
    end
  end
end
