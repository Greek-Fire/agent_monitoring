module AgentMonitoring
  class AgentsController < ApplicationController
    include Foreman::Controller::AutoCompleteSearch
    def index
      @agents = resource_base_search_and_page
    end
  end
end
