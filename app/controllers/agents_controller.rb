class AgentsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  
    def index
      @agents = Agent.fetch(params)# For now, we'll just render a simple text response
    end
  end
  