class QueryBuilder::CollectiveFilter < QueryBuilder::Filter
  def initialize(filters)
    @filters = filters
  end

  def type
    if @filters.length == 1
      @filters.first.type
    else
      collective_type
    end
  end

  def value
    if @filters.length == 1
      @filters.first.value
    else
      @filters.map(&:to_h)
    end
  end

  def present?
    @filters.present?
  end

  def blank?
    @filters.blank?
  end

  def length
    present? ? 1 : 0
  end
end