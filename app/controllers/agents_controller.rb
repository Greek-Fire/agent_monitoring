module AgentMonitoring
  class AgentsController < ApplicationController
    include Foreman::Controller::AutoCompleteSearch
    def index
      @agents = resource_base_search_and_page.search_for(params[:search])
    end
  end
end
