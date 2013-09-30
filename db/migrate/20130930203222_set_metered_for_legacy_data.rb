class SetMeteredForLegacyData < ActiveRecord::Migration
  def up
    AudioFile.find_each do |audio_file|
      audio_file.send(:set_metered)
      audio_file.save
    end
  end
end
