object false

if current_user
  node(:id) { current_user.id }
  node(:uri) { "http://pop-up-archive.org/api/users/#{current_user.id}" }
  node(:uploads_collection_id) { current_user.uploads_collection_id }
  node(:collection_ids) { current_user.collection_ids }
end

