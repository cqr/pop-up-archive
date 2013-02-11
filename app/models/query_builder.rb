class QueryBuilder

  attr_accessor :params

  def initialize(params)
    self.params = params
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
    (facet_params).map do |name, details|
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

  class Facet

    attr_accessor :name, :type, :field_name, :options

    def initialize(name)
      self.field_name = name
      self.name = "facet_#{name}"
    end

    def block
      lambda {|x| x.send(:"#{type}", *arguments) }
    end

    private

    def arguments
      [field_name.intern, options || default_options]
    end

    def default_options
      case type
      when 'date' then {interval: 'year'}
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
    {}
  end
end