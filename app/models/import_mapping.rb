class ImportMapping < ActiveRecord::Base
  belongs_to :csv_import
  attr_accessible :column, :type
  acts_as_list scope: :csv_import_id

  def type=(val)
    self.data_type = val
  end
end
