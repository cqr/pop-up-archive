class Api::V1::CollectionsController < Api::V1::BaseController
  expose(:collections, ancestor: :current_user)
  expose(:collection)
  expose(:kollection) { collection }

  def create
    if collection.save
      current_user.collections << collection
      current_user.save
    end
    respond_with :api, collection
  end

  def update
    collection.save
    respond_with :api, collection
  end 

  def destroy
    collection.delete
    respond_with :api, collection
  end
end
