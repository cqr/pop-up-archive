class Api::V1::SearchesController < Api::V1::BaseController
  def show
    query_builder = QueryBuilder.new(params, current_user)
    page = params[:page].to_i

    logger.debug(Tire.search('items')do
      if page.present? && page > 1
        from (page - 1) * 25
      end
      size 25

      query_builder.query do |q|
        query &q
      end

      query_builder.facets do |my_facet|
        facet my_facet.name, &my_facet
      end

      query_builder.filters do |my_filter|
        filter my_filter.type, my_filter.value
      end

      highlight options: {order: 'score'}, transcript: { number_of_fragments: 0 }
    end.to_curl)

    @search = ItemResultsPresenter.new(Item.search do

      if page.present? && page > 1
        from (page - 1) * 25
      end
      size 25

      query_builder.query do |q|
        query &q
      end

      query_builder.facets do |my_facet|
        facet my_facet.name, &my_facet
      end

      query_builder.filters do |my_filter|
        filter my_filter.type, my_filter.value
      end

      highlight transcript: { number_of_fragments: 0 }
    end)

    respond_with @search
  end
end
