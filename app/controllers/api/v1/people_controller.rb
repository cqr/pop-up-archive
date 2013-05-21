class Api::V1::PeopleController < Api::V1::BaseController
  expose(:collection)
  expose(:person)

  expose(:search_people) do
    params[:q].blank? ? []: Person.search_within_collection(collection.id, params[:q]).collect{|p|p}
  end

  # caches_action :index, :expires_in => 1.hour

  def index
    respond_with :api, search_people
  end

  def create
    person.valid?
    person.save
    respond_with :api, person
  end

end
