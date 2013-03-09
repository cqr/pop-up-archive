class Api::V1::CsvImportsController < Api::V1::BaseController
  expose(:csv_import)
  expose(:csv_imports, ancestor: :current_user)
  
  def create
    csv_import.user_id = current_user.id
    csv_import.save
    respond_with(:api, csv_import)
  end

  def update
    csv_import.save
    respond_with(:api, csv_import)
  end
end
