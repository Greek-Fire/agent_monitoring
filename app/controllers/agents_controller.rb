module AgentMonitoring
    class AgentsController < ApplicationController
      def index
        # For now, we'll just render a simple text response
        render plain: "This is the Agents index page"
      end
    end
  end
  