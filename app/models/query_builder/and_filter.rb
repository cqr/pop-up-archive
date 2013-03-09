class QueryBuilder::AndFilter < QueryBuilder::CollectiveFilter
  def collective_type
    :and
  end
end