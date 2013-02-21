class Api::V1::SearchesController < Api::V1::BaseController
  def show
    query_builder = QueryBuilder.new(params)

    @search = Item.search do
      query_builder.query do |q|
        query &q
      end

      query_builder.facets.each do |f|
        facet f.name, &f
      end

      query_builder.filters.each do |f|
        filter f.type, f.value
      end

    end

    respond_with @search
  end
end
