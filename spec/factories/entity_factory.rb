FactoryGirl.define do

  sequence (:high_score) { (95 + rand(5))/ 100.0 }
  sequence (:middle_score) { (75 + rand(19)) / 100.0 }
  sequence (:low_score) { (50 + rand(24)) / 100.0 }

  factory :entity do

    factory :mid_entity do
      score { generate :middle_score }
    end

    factory :high_entity do
      score { generate :high_score }
    end

    factory :low_entity do
      score { rand(1) > 0.5 ? nil : generate(:low_score) }
    end

  end
end