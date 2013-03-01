class QueryBuilder

  DEFAULT_FACETS = {date_created: {type:'date'}, date_broadcast: {type:'date'}, date_added: {type:'date'}, duration: {type:'histogram'}, interviewer:{}, interviewee:{}, producer:{}, creator:{}, tag:{}}

  attr_accessor :params, :current_user

  def initialize(params, current_user)
    self.params = params
    self.current_user = current_user
  end

  def query
    if query_string
      yield QueryString.new(query_string)
    end
  end

  def facets
    facet_params.map do |name, details|
      Facet.new(name, details, filters).tap do |facet|
        yield facet if block_given?
      end
    end
  end

  def filters
    @_filters ||= filter_params.map {|name, details| Filter.new(name, details) }
    (@_totalFilter ||= [AndFilter.new(@_filters)]).tap do |filter|
      yield filter[0] if block_given? && filter[0].present?
    end
  end

  private

  def query_string
    params[:query]
  end

  def sort_column
    params[:sort_by] || :date_created
  end

  def sort_order
    params[:sort_order] || 'desc'
  end

  private

  def facet_params
    if params[:facets].present?
      params[:facets]
    elsif params[:facet].present?
      if params[:facet].kind_of? String
        {params[:facet] => {}}
      else
        {params[:facet].delete(:name) => params[:facet]}
      end
    else
      DEFAULT_FACETS
    end
  end

  def filter_params
    return params[:filters] if params[:filters].present?
    {}
  end
end