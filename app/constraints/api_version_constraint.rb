class ApiVersionConstraint < Struct.new(:options)
  def matches?(request)
    options[:default] || request.headers['Accept'].include?("application/vnd.pop-up-archive.v#{options[:version]}+json")
  end
end
