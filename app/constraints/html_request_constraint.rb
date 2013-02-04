class HtmlRequestConstraint < Struct.new(:options)
  def matches?(request)
    options[:default] || request.headers['Accept'].include?("text/html")
  end
end
