FactoryGirl.define do
  factory :storage_configuration do
    initialize_with { StorageConfiguration.private_storage }

    factory :storage_configuration_public do
      initialize_with { StorageConfiguration.public_storage }
    end

    factory :storage_configuration_private do
      initialize_with { StorageConfiguration.private_storage }
    end
  end
end
