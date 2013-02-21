object false

node(:facets, if: @search.facets.present? )  { @search.facets }
node(:total_hits) { @search.total }
node(:page) { ((@search.options[:from] || 0) / 25) + 1 }
node(:max_score) { @search.max_score }
node(:query) { params[:query] }

node 'results' do
  @search.results.to_a.map do |result|
    partial('api/v1/items/item', object: result)
  end
end