module AgentMonitoring
  class AgentsController < ApplicationController
    include Foreman::Controller::AutoCompleteSearch
    def index
      @agents = rresource_base_search_and_page
    end
  end
end
