FactoryGirl.define do
  factory :audio_file do
    item
    after(:create) { |af| af.update_file!('test.mp3', 0) }
  end
end
