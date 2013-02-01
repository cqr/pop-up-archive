object inferred_model(params[:controller])
extends "#{params[:controller]}/show"

node :created do |n|
	n.valid?
end