module AgentMonitoring
  class AgentsController < ApplicationController
    include Foreman::Controller::AutoCompleteSearch

    def index
      @agents = Agent.fetch(params)
      if @agents.empty?
        render 'welcome'  # Render the welcome view if no agents are found
      else
        render 'index'  # Otherwise, render the index view
      end
    end
  end
end
