class Api::V1::PeopleController < Api::V1::BaseController
  expose(:collection)
  expose(:people) do
    params[:q].blank? ? [] : Person.search_within_collection(collection.id, params[:q]).collect{|p|p}
  end
  expose(:person)

  # caches_action :index, :expires_in => 1.hour

  def index
    respond_with :api, people
  end

end
