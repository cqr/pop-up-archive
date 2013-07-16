class Api::V1::ContributionsController < Api::V1::BaseController
  expose :item
  expose :contributions, ancestor: :item
  expose :contribution

  authorize_resource decent_exposure: true

  def create
    contribution.save
    respond_with :api, contribution
  end

  def update
    contribution.save
    respond_with :api, contribution
  end

  def destroy
    contribution.destroy
    respond_with :api, contribution
  end

end
