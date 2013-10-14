class Api::V1::SubscriptionsController < Api::V1::BaseController

  def update
    current_user.subscribe!(SubscriptionPlan.find(params[:subscription][:plan_id]))
    render status: 200, json: {status: 'OK'}
  end

end
