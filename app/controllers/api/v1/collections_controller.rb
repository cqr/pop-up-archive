class Api::V1::CollectionsController < Api::V1::BaseController
  expose(:collections)
  expose(:collection)
  expose(:kollection) { collection }

  def create
    collection.save
    respond_with :api, collection
  end

  def destroy
    collection.delete
    respond_with :api, collection
  end
end
