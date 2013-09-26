FactoryGirl.define do
  factory :organization do

    name "test org"

    factory :organization_amara do
      amara_key "amara_key"
      amara_username "amara_username"
      amara_team "amara_team"
      is_transcriber true
    end

  end
end