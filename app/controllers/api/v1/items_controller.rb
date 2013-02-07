class Api::V1::ItemsController < Api::V1::BaseController
  expose(:items) { Item.limit(100) }
  expose(:item)
end
