object false

node(:facets, if: @search.facets.present? )  { @search.facets }

node(:max_score) { @search.max_score }
node(:query) { params[:query] }

node 'results' do
  @search.results.map do |result|
    partial('api/v1/items/item', object: result)
  end
end