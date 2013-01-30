class CsvRow < ActiveRecord::Base
  belongs_to :csv_import
  attr_accessible :index, :values
end
