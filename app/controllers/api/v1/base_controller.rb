class Api::V1::BaseController < Api::BaseController
  respond_to :json

  # this should protect the resources using oauth when user is not logged in (i.e. API requests)
  # doorkeeper_for :create, :update, :destroy, if: lambda{|c| !current_user }

end
