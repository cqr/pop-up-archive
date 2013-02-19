class Api::V1::AudioFilesController < Api::V1::BaseController
  expose :audio_files
  expose :audio_file

  def update
    if params[:task].present? && params[:task][:result_details][:status] == 'complete'
      audio_file.update_from_fixer(params[:task])
    else
      audio_file.update_attributes(params[:audio_file])
    end
    respond_with :api, audio_file.item, audio_file
  end
end