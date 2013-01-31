class Api::V1::CsvImportsController < Api::V1::BaseController
  expose(:csv_import)

  def create
    if csv_import.save
      # redirect_to(api_csv_import_path(csv_import))
      respond_with(:api, csv_import)
    else
      respond_with(:api, csv_import)
    end
    # respond_with(:api, csv_import, :location => api_csv_import_path(csv_import))
  end
end
