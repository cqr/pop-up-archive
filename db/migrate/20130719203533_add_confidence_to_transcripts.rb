class AddConfidenceToTranscripts < ActiveRecord::Migration
  def change
    add_column :transcripts, :confidence, :decimal    
  end
end
