  class QueryBuilder::Facet

    attr_accessor :name, :options, :filters

    def initialize(name, options={}, filters=[])
      @name = name
      @type = options.delete(:type)
      @options = options
      @filters = filters
    end

    def to_proc
      lambda do |search|
        search.send(:"#{type}", name.intern, options)
        unless options['global'] || filters.blank?
          if filters.length > 1
            search.facet_filter :and, filters.map(&:to_hash)
          else
            search.facet_filter filters.first.type, filters.first.value
          end
        end
      end
    end

    private

    def options
      @options.present? ? @options : default_options
    end

    def type
      @type || 'terms'
    end

    def default_options
      case type.to_s
      when 'date' then {interval: 'year'}
      when 'histogram' then {interval: 60*5}
      else {}
      end
    end
  end