FactoryGirl.define do
  factory :collection do

    title "test collection"
    items_visible_by_default true
    association :default_storage, factory: :storage_configuration_public
    association :upload_storage, factory: :storage_configuration_private
  
    factory :collection_public do
      items_visible_by_default true
      association :default_storage, factory: :storage_configuration_public
      association :upload_storage, factory: :storage_configuration_private
    end

    factory :collection_private do
      items_visible_by_default false
      association :default_storage, factory: :storage_configuration_private
    end
    
  end
end