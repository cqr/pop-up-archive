object false

if current_user
  node(:id) { current_user.id }
  node(:uri) { "http://pop-up-archive.org/api/users/#{current_user.id}" }
  node(:uploads_collection_id) { current_user.uploads_collection.id }
  node(:collection_ids) { current_user.collection_ids }

  node(:role) { current_user.role }

  node(:organization) {
    {
      id: current_user.organization.id,
      name: current_user.organization.name
    }
  }

end
