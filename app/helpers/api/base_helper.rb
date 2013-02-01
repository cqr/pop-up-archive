module Api::BaseHelper
	def infer_model_name(controller)
		controller.camelize.demodulize.underscore.singularize.intern
	end

	def inferred_model(controller)
		send(infer_model_name(controller))
	end
end