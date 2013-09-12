FactoryGirl.define do
  factory :item do
    association :collection, factory: :collection_public

    factory :item_private do
      association :collection, factory: :collection_private
    end

  end

end