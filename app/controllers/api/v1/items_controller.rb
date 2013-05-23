class Api::V1::ItemsController < Api::V1::BaseController
  expose(:collection)
  expose(:items, ancestor: :collection)
  expose(:item)
  expose(:contributions, ancestor: :item)

  expose(:searched_item) do
    query_builder = QueryBuilder.new({query:"id:#{params[:id].to_i}"}, current_user)
    Item.search do
      query_builder.query do |q|
        query &q
      end
      query_builder.filters do |f|
        filter f.type, f.value
      end
    end.first.tap do |item|
      if item.blank?
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  authorize_resource decent_exposure: true

  def update
    item.save
    respond_with :api, item
  end

  def show
    respond_with :api, searched_item
  end

  def create
    item.valid?
    item.save
    respond_with :api, item
  end
end
