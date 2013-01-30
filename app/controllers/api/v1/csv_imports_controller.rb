class Api::V1::CsvImportsController < Api::V1::BaseController
  expose(:csv_import)

  def create
    csv_import.save
    respond_with csv_import, location: api_csv_import_url(csv_import.id || 0)
  end
end
