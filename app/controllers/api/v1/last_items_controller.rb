class Api::V1::LastItemsController < Api::V1::BaseController
	def show
    @list =  Item.where("is_public = true").find(:all, :order => "updated_at DESC", :limit => 6)
    respond_with @list
  end
end
