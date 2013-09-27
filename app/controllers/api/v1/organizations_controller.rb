class Api::V1::OrganizationsController < Api::V1::BaseController
  expose(:organization)

  def show
    respond_with :api, organization
  end

end
