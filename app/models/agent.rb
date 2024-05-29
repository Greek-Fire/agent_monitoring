class Agent < ApplicationRecord
    
    scoped_search on: :network, complete_value: true
    scoped_search on: :status, complete_value: true
    scoped_search on: :agent, complete_value: true
    scoped_search on: :host
  
    def self.fetch(params)
        list = select_counts
                .with_counts
                .search_for(params[:search])
                .order(params[:order])
                .paginate(page: params[:page], per_page: params[:per_page])
      end
    
end