class Api::V1::CollectionsController < Api::V1::BaseController
  expose(:collections, ancestor: :current_user)
  expose(:kollection) { current_user.collections.find_by_id(params[:id]) || Collection.is_public.find(params[:id])}

  def create
    if kollection.save
      current_user.collections << kollection
      current_user.save
    end
    respond_with :api, kollection
  end

  def update
    kollection.save
    respond_with :api, kollection
  end 

  def destroy
    kollection.destroy
    respond_with :api, kollection
  end
end
