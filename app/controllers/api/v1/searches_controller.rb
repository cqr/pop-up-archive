class Api::V1::SearchesController < Api::V1::BaseController
  def show
    query_builder = QueryBuilder.new(params)
    page = params[:page].to_i

    @search = Item.search do


      if page.present? && page > 1
        from (page - 1) * 25
      end
      size 25

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

    Rails.logger.debug(@search.inspect)

    respond_with @search
  end
end
