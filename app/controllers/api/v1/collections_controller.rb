class Api::V1::CollectionsController < Api::V1::BaseController
  expose(:collections)
  expose(:collection)

  def create
    if collection.save
      render json: item, status: :created, location: item
    else
      render json: item.errors, status: :unprocessable_entity
    end
  end
end
