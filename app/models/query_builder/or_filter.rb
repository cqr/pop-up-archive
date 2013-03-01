class QueryBuilder::OrFilter < QueryBuilder::CollectiveFilter
  def collective_type
    :or
  end
end