class Api::V1::CsvImportsController < Api::V1::BaseController
  expose(:csv_import)

  def create
    csv_import.save
    respond_with(:api, csv_import)
  end
end
