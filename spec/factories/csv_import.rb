FactoryGirl.define do
  factory :csv_import do
    file_name "import.csv"
    file { Upload.file('example.csv', 'text/csv') }
  end
end