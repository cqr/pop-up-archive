class Api::V1::ItemsController < Api::V1::BaseController
  expose(:items) { Item.limit(5) }
  expose(:item)
end
