class QueryBuilder

  DEFAULT_FACETS = {date_created: {type:'date'}, date_broadcast: {type:'date'}, date_added: {type:'date'}, duration: {type:'histogram'}, interviewer:{}, interviewee:{}, producer:{}, creator:{}, tag:{}}

  attr_accessor :params

  def initialize(params)
    self.params = params
  end

  def query
    if query_string
      yield(QueryString.new(query_string))
    end
  end

  def query_string
    params[:query]
  end

  def sort_column
    params[:sort_by] || :date_created
  end

  def sort_order
    params[:sort_order] || 'desc'
  end

  def facets
    facet_params.map do |name, details|
      Facet.new(name).tap do |facet|
        if details.present?
          facet.type = details[:type]
          facet.options = details[:options]
        else
          facet.type = 'terms'
        end
      end
    end
  end

  def filters
    filter_params.map do |name, value|
      Filter.new(name, value)
    end
  end

  class Facet

    attr_accessor :name, :type, :field_name, :options

    def initialize(name)
      self.field_name = name
      self.name = "#{name}"
    end

    def to_proc
      lambda {|x| x.send(:"#{type}", *arguments) }
    end

    private

    def arguments
      [field_name.intern, options || default_options]
    end

    def default_options
      case type
      when 'date' then {interval: 'year'}
      when 'histogram' then {interval: 1}
      else {}
      end
    end
  end

  private

  def facet_params
    return params[:facets] if params[:facets].present?
    if params[:facet].present?
      return {:"#{params[:facet].delete(:name)}" => params[:facet]}
    end
    DEFAULT_FACETS
  end

  def filter_params
    return params[:filters] if params[:filters].present?
    {}
  end


  class QueryString
    def initialize(query_string)
      @query_string = query_string
    end

    def to_proc
      lambda {|x| x.string @query_string }
    end
  end

  class MatchAll
    def to_proc
      lambda {|x| x.match_all }
    end
  end

  class Filter
    def initialize(name, value)
      @name         = name
      @type, @pairs = decode_value(value)
    end

    def to_proc
      lambda {|x| x.send(value[0].intern, value[1])}
    end

    def type
      @type
    end

    def value
      @pairs
    end

    private

    def decode_value(value)
      if value.kind_of? String
        [:term, {@name => value}]
      else
        [value[:type], {@name => value[:value]}]
      end
    end
  end
end