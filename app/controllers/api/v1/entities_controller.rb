class Api::V1::EntitiesController < Api::V1::BaseController
  expose :item
  expose :entities, ancestor: :item
  expose :entity

  authorize_resource decent_exposure: true

  def update
    entity.save
    respond_with :api, entity
  end

  def destroy
    entity.destroy
    respond_with :api, entity
  end

end
