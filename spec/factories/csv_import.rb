FactoryGirl.define do
  factory :csv_import do
    file { Upload.file('example.csv', 'text/csv') }
  
    factory :csv_import_with_bad_file do
      file { Upload.file('example.png', 'image/png')}
    end

    factory :csv_import_with_no_file do
      file nil
    end
    
  end
end