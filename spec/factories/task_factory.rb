FactoryGirl.define do
  factory :task do
    association :owner, factory: :audio_file
  end

  factory :transcribe_task, parent: :task, class: Tasks::TranscribeTask do
  end

  factory :analyze_task, parent: :task, class: Tasks::AnalyzeTask do
  end
end