class Api::V1::SearchesController < Api::V1::BaseController
  def show
    query_builder = QueryBuilder.new(params)

    @search = Item.search do
      query { string query_builder.query_string }

      # filter :or do
      #   filter :term, public: true
      #   filter :in, collection_id: current_user.collection_ids, execution: 'bool'
      # end
      
      # sort  { by query_builder.sort_column, query_builder.sort_order }
      query_builder.facets.each do |f|
        facet f.name, &f.block
      end
    end

    respond_with @search
  end
end
