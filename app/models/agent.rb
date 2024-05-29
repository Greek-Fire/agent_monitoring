class Agent < ApplicationRecord
  scoped_search on: :network, complete_value: true
  scoped_search on: :status, complete_value: true
  scoped_search on: :agent, complete_value: true
  scoped_search on: :host

  def self.fetch(params)
    list = self
            .search_for(params[:search])
            .order(params[:order])
            .paginate(page: params[:page], per_page: params[:per_page])
    list
  end
end
