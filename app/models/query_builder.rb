class QueryBuilder

  attr_accessor :params

  def initialize(params)
    self.params = params
  end

  def query_string
    params[:query]
  end

  def sort_column
    params[:sort_by] || :created_at
  end

  def sort_order
    params[:sort_order] || 'desc'
  end
end