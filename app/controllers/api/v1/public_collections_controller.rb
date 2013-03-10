class Api::V1::PublicCollectionsController < Api::V1::BaseController
  expose(:public_collections) { Collection.public }

  def index
    respond_with :api, public_collections
  end
end
