class Api::V1::SearchesController < Api::V1::BaseController
  def show
    query_builder = QueryBuilder.new(params)
    
    @results = Item.search do
      query { string query_builder.query_string }
      sort  { by query_builder.sort_column, query_builder.sort_order }
    end

    respond_with @results
  end
end
