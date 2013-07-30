module Api::BaseHelper
  def infer_model_name(controller)
    controller.camelize.demodulize.underscore.singularize.intern
  end

  def inferred_model(controller)
    send(infer_model_name(controller))
  end

  def format_time(seconds)
    Time.at(seconds).getgm.strftime('%H:%M:%S')
  end
end
