class Api::V1::CollectionsController < Api::V1::BaseController
  expose :collections do
    if user_signed_in?
      current_user.collections
    else
      []
    end
  end
  expose :kollection do
    if params[:id]
      if user_signed_in?
        current_user.collections.find_by_id(params[:id]) 
      end || Collection.is_public.find_by_id(params[:id])
    else
      Collection.new(params[:collection].merge(creator: current_user))
    end
  end

  expose :collection do 
    kollection
  end

  def create
    kollection.save
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
