class Api::V1::AudioFilesController < Api::V1::BaseController
  expose :item
  expose :audio_files, ancestor: :item
  expose :audio_file

  def update
    if params[:task].present? && params[:task][:result_details][:status] == 'complete'
      audio_file.update_from_fixer(params[:task])
    else
      audio_file.update_attributes(params[:audio_file])
    end
    respond_with :api, audio_file.item, audio_file
  end

  def create
    if params[:file]
      audio_file.file = params[:file]
    end
    audio_file.save
    respond_with :api, audio_file.item, audio_file
  end
end