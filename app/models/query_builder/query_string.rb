class QueryString
  def initialize(query_string)
    @query_string = query_string
  end

  def to_proc
    lambda {|x| x.string @query_string }
  end
end