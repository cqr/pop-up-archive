class HtmlRequestConstraint < Struct.new(:options)
  def matches?(request)
     action_dispatch_html_request?(request) || accept_html_request?(request)
  end

  def action_dispatch_html_request?(request)
    if request['action_dispatch.request.path_parameters'].present?
      request['action_dispatch.request.path_parameters'][:format] == "html"
    end
  end

  def accept_html_request?(request)
    if request.headers['Accept'].present?
      request.headers['Accept'].include?("text/html")
    end
  end
end
