class ImportMapping < ActiveRecord::Base
  belongs_to :csv_import
  attr_accessible :column, :data_type
  acts_as_list scope: :csv_import_id
end
